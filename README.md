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
.github/workflows/cicd.yml
```

The workflow runs on:

- Pushes to `main` or `develop`
- Pull requests targeting `main` or `develop`
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
   - Downloads the built Docker image artifacts.
   - Scans both images with Trivy.
   - Scans OS and application/library dependencies.
   - Generates SARIF results for `HIGH` and `CRITICAL` findings.
   - Uploads the SARIF results to GitHub Code scanning so findings are visible in the repository Security tab.

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

This project uses two complementary security feedback paths: Trivy scans the built container images and uploads SARIF results to GitHub Code scanning, while Dependabot monitors source-level dependencies and opens update pull requests when configured updates or security fixes are available.

The Trivy scan is configured to report `HIGH` and `CRITICAL` vulnerabilities in:

```text
os,library
```

This means Trivy scans both:

- Operating system packages inside the container images
- Application/library dependencies such as Ruby gems and Node packages

During remediation, an unused `thruster` dependency was removed from the Rails API image. This reduced the runtime image attack surface and eliminated an unnecessary embedded Go binary from the scan results. The Rails API image also no longer installs `nodejs`: the app is API-only (no importmap, jsbundling, or asset pipeline gem depends on a JS runtime), so the package was dead weight that only added its own vendored Node dependencies -- including a vulnerable `brace-expansion` -- to the scan surface.

The Rails API image currently pins patched versions of `json` and `net-imap` in `Gemfile` and `Gemfile.lock` after Trivy identified older Ruby-provided versions in the container image. Trivy may still report stale/default Ruby gem metadata inherited from the upstream Ruby base image. Trivy findings are always uploaded to the Security tab, but whether they block the pipeline depends on the branch: on `develop`, Trivy is a reporting control only, so feature work can be validated without a scan finding halting the run; on `main`, a `HIGH` or `CRITICAL` finding fails the `security-scan` job and blocks `publish`, since `main` is the only branch that pushes images to GitHub Container Registry. In a professional production setting, I would also route findings into a vulnerability tracking process with defined ownership, remediation timelines, and escalation criteria. For example, findings could be tracked against the application-owning team with a defined remediation window, while deployment blocking could be reserved for actively exploited, internet-exposed, or policy-exception cases.

The workflow also uses GitHub Actions token permissions with least privilege:

- The workflow defaults to `contents: read`.
- The `security-scan` job receives `security-events: write` so it can upload SARIF results to GitHub Code scanning.
- The `publish` job alone receives `packages: write` so it can publish images to GitHub Container Registry.

## Dependency and Supply Chain Monitoring

This repository also uses GitHub's dependency graph and Dependabot to improve supply chain visibility.

Dependabot is configured to monitor and update dependencies across:

- Ruby dependencies in `bowling_api` and `bowling_core`
- Node dependencies in `bowling_ui`
- GitHub Actions workflow dependencies
- Docker base images for the API and UI images

Routine version update checks are configured in:

```text
.github/dependabot.yml
```

Dependabot version updates are scheduled monthly to reduce unnecessary pull request noise while still maintaining dependency visibility. Dependabot alerts and security updates are also enabled so vulnerable dependencies can be identified and remediated through pull requests when fixes are available.

## Running the Application from Published Images

After the images are published, the application can be run locally with Docker Compose. The relevant Compose file is named `docker-compose.yml`.

From the repository root:

```bash
docker compose up -d
```

Docker Compose will create the application network, pull the published images if they are not already present locally, and start both containers.

Open the application:

```text
http://localhost:8085
```

The root `docker-compose.yml` exposes only the UI container to the host on port `8085`. The API container is not published directly to the host; it is reachable by the UI container over the Docker Compose network using the `bowling_api` service name.

To stop and remove the containers and network created by Docker Compose:

```bash
docker compose down
```

To explicitly refresh the published images before restarting the application:

```bash
docker compose pull
docker compose up -d
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

```bash
docker build \
  -t bowling-game-scorer-api:local \
  -f ./bowling_api/Dockerfile \
  .
```

```bash
docker build \
  -t bowling-game-scorer-ui:local \
  ./bowling_ui
```

Create a local test network:

```bash
docker network create bowling-game-scorer-net
```

Run the local API image:

```bash
docker run -d \
  --name bowling-game-scorer-api \
  --network bowling-game-scorer-net \
  --network-alias bowling_api \
  bowling-game-scorer-api:local
```

Run the local UI image:

```bash
docker run -d \
  --name bowling-game-scorer-ui \
  --network bowling-game-scorer-net \
  -p 8085:80 \
  bowling-game-scorer-ui:local
```

Open:

```text
http://localhost:8085
```

To clean up the local Docker test containers, network, and images:

```bash
docker rm -f bowling-game-scorer-api bowling-game-scorer-ui
docker network rm bowling-game-scorer-net
docker rmi bowling-game-scorer-api:local bowling-game-scorer-ui:local
```

## Future Improvements

If this project were extended further, I would focus on:

- **Vulnerability management** – Integrate Trivy findings with a vulnerability tracking process that supports ownership, remediation timelines, escalation, and risk-based deployment gates.
- **Branch protection through CI enforcement** – Require successful continuous integration checks before pull requests can be merged. This ensures that builds, tests, and security checks pass before code is promoted.
- **Active security controls** – Migrate to a more feature-rich reverse proxy that supports intrusion prevention systems. This would build on my existing intrusion detection setup by adding remediation and enforcement capabilities.
- **Branching model** – A `main`/`develop`/feature branching model is now in place, with CI/CD (including Trivy scanning) running on both `main` and `develop`. If this product were being released in a corporate environment with distributed systems, user data, and multiple deployment stages, I would extend this further with dedicated release branches for release stabilization and clearer traceability between tested release candidates and production deployments.
- **User Experience** - Input field shouldn't require space/comma input from the user as a separator of bowling roll values. A user should be able to enter each roll value, and then the application should automatically insert a comma IF the user begins to enter an additional roll value (ie User types 'X', then '7'. The application automatically inserts a comma between the two values).
