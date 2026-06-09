# Bowling Game Scorer – Full Stack Demo

This project is a full-stack bowling score calculator built to demonstrate clean domain logic, API design, and a simple user interface.

The application consists of three main parts:

- **bowling_core** – Shared scoring logic
- **bowling_api** – API that exposes the scoring functionality
- **bowling_ui** – User interface that consumes the API

---

## Prerequisites

This project is designed to be run using **VS Code Dev Containers**.

You will need:

- VS Code
- Docker Desktop
- VS Code extension/s:
  - Remote Development (Extension pack by Microsoft)
    - https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.vscode-remote-extensionpack
    - Contains the following extensions:
      - Dev Containers
      - Remote - SSH
      - Remote - WSL
      - Remote - Tunnels

(If you already have Ruby, Rails, Node, and npm installed locally, then you can also run it natively.)

---

## Running the Application

You will need **two terminals**:

- One for the back-end API
- One for the front-end UI.

From the project root (each 'install' command only need to be run once to initially install the necessary tools in your local repository):

### 1. Start the API

In terminal 1:

```bash
cd bowling_api
bundle install
bin/rails s -b 0.0.0.0 -p 3000
```

The API will be available at:

- http://localhost:3000

### 2. Start the UI

In terminal 2:

```bash
cd bowling_ui
npm install
npm run dev
```

The UI will be available at:

- http://localhost:5173
