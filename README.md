# Bowling Game Scorer – Full Stack CI/CD Demo

This repository contains a full-stack bowling score calculator used to demonstrate a security-focused CI/CD pipeline with GitHub Actions.

## Application Overview

The project contains three main components:

- **`bowling_core`** – Shared Ruby bowling scoring logic.
- **`bowling_api`** – Ruby on Rails API that exposes scoring functionality.
- **`bowling_ui`** – React front end that consumes the API.

## CI/CD Overview

The main workflow is located at:

```text
.github/workflows/cicd-prod.yaml
```

The workflow runs on:

- Pushes to `main`
- Pull requests targeting `main`
- Manual runs through `workflow_dispatch`

The workflow includes the following jobs:

1. **Frontend build**
   - Checks out the repository.
   - Sets up Node.js.
   - Installs UI dependencies with `npm ci`.
   - Builds the React UI with `npm run build`.

2. **Backend test**
   - Checks out the repository.
   - Sets up Ruby.
   - Installs Rails API dependencies with Bundler.
   - Prepares the test database.
   - Runs backend tests with RSpec.

3. **Docker build**
   - Builds the Rails API Docker image.
   - Builds the React/Nginx UI Docker image.
   - Saves both images as tar artifacts for later workflow jobs.

4. **Security scan**
   - Downloads the built image artifacts.
   - Scans both Docker images with Trivy.
   - Scans OS and application/library dependencies.
   - Reports `HIGH` and `CRITICAL` findings.

5. **Publish**
   - Runs only for pushes to `main` or manual runs from `main`.
   - Downloads the same image artifacts that were built and scanned.
   - Loads, tags, and publishes the API and UI images to GitHub Container Registry.

## Published Docker Images

The workflow publishes two images to GitHub Container Registry:

```text
ghcr.io/kabaize/bowling-game-scorer-api
ghcr.io/kabaize/bowling-game-scorer-ui
```

Each successful publish creates:

- `latest`
- a commit-SHA tag

This provides both a convenient latest image and a traceable immutable image reference for a specific commit.

## Security Notes

This pipeline includes container image scanning with Trivy.

The Trivy scan is configured to report `HIGH` and `CRITICAL` vulnerabilities in:

```text
os,library
```

This means Trivy scans both:

- Operating system packages inside the container images
- Application/library dependencies such as Ruby gems and Node packages

During remediation, an unused `thruster` dependency was removed from the Rails API image. This reduced the runtime image attack surface and eliminated an unnecessary embedded Go binary from the scan results.

The Rails API image currently pins patched versions of vulnerable `json` and `net-imap` dependencies in `Gemfile` and `Gemfile.lock`. Trivy may still report stale/default Ruby gem metadata inherited from the upstream Ruby base image. For this exercise, Trivy is retained as a reporting control rather than a blocking deployment gate so the full CI/CD pipeline can complete. In a production setting, I would make the scan a blocking deployment gate after moving to a patched base image or otherwise eliminating inherited image findings.

The workflow also uses GitHub Actions token permissions with least privilege:

- The workflow defaults to `contents: read`.
- The `publish` job alone receives `packages: write` so it can publish images to GitHub Container Registry.

## Running the Application from Published Images

After the images are published, the application can be run locally with Docker.

Create a Docker network:

```powershell
docker network create bowling-game-scorer-net
```

Pull the published images:

```powershell
docker pull ghcr.io/kabaize/bowling-game-scorer-api:latest
docker pull ghcr.io/kabaize/bowling-game-scorer-ui:latest
```

Run the API container:

```powershell
docker run -d `
  --name bowling-game-scorer-api `
  --network bowling-game-scorer-net `
  --network-alias bowling_api `
  -p 3000:3000 `
  ghcr.io/kabaize/bowling-game-scorer-api:latest
```

Run the UI container:

```powershell
docker run -d `
  --name bowling-game-scorer-ui `
  --network bowling-game-scorer-net `
  -p 8085:80 `
  ghcr.io/kabaize/bowling-game-scorer-ui:latest
```

Open the application:

```text
http://localhost:8085
```

The API container uses the network alias `bowling_api` because the UI container’s Nginx configuration proxies API requests to that hostname.

To clean up local test containers:

```powershell
docker rm -f bowling-game-scorer-api bowling-game-scorer-ui
docker network rm bowling-game-scorer-net
```

Optionally remove the pulled images:

```powershell
docker rmi ghcr.io/kabaize/bowling-game-scorer-api:latest ghcr.io/kabaize/bowling-game-scorer-ui:latest
```

## Running the Application for Local Development

This project can also be run locally without pulling the published images.

### API

From the repository root:

```bash
cd bowling_api
bundle install
bundle exec rails s -b 0.0.0.0 -p 3000
```

The API will be available at:

```text
http://localhost:3000
```

### UI

In a separate terminal:

```bash
cd bowling_ui
npm install
npm run dev
```

The UI development server will be available at:

```text
http://localhost:5173
```

## Running Tests Locally

From the Rails API directory:

```bash
cd bowling_api
bundle exec rails db:prepare
bundle exec rspec
```

The GitHub Actions backend job runs these same RSpec tests. If the tests fail, the backend job fails and later Docker build, security scan, and publish jobs do not run.

## Building Docker Images Locally

From the repository root:

```powershell
docker build `
  -t bowling-game-scorer-api:local `
  -f .\bowling_api\Dockerfile `
  .
```

```powershell
docker build `
  -t bowling-game-scorer-ui:local `
  .\bowling_ui
```

Create a local test network:

```powershell
docker network create bowling-game-scorer-net
```

Run the local API image:

```powershell
docker run -d `
  --name bowling-game-scorer-api `
  --network bowling-game-scorer-net `
  --network-alias bowling_api `
  -p 3000:3000 `
  bowling-game-scorer-api:local
```

Run the local UI image:

```powershell
docker run -d `
  --name bowling-game-scorer-ui `
  --network bowling-game-scorer-net `
  -p 8085:80 `
  bowling-game-scorer-ui:local
```

Open:

```text
http://localhost:8085
```

Clean up:

```powershell
docker rm -f bowling-game-scorer-api bowling-game-scorer-ui
docker network rm bowling-game-scorer-net
docker rmi bowling-game-scorer-api:local bowling-game-scorer-ui:local
```

## Future Improvements

If this project were extended further, I would focus on:

- **Repository and pipeline enforcement** – Add branch protection rules, require successful CI checks before merging, and make Trivy a blocking deployment gate after targeted-severity vulnerabilities are remediated.
- **Supply-chain and secrets hardening** – Pin base images by digest, automate dependency updates, and add a more formal secrets management pattern for deployment credentials and runtime configuration.
- **Operational readiness** – Add observability, deployment runbooks, expanded test coverage, and a production Docker Compose deployment target with documented rollback steps.
