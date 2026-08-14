# DeepSeek Harness Docker Auto-Builder

This repository is a dedicated **Automated Docker Build Configuration** for the official [DeepSeek Harness](https://github.com/deepseek-ai/deepseek-harness).

## Architecture

This repository has been decoupled from the upstream source code. It serves solely as a GitHub Actions pipeline to automatically build and publish Docker images.

- **Upstream Sync**: It does not require manual source code syncing. The GitHub Action pulls the latest source code directly from `deepseek-ai/deepseek-harness` during the build phase.
- **Daily Builds**: A scheduled job runs every day at 0:00 UTC (8:00 AM Beijing time) to ensure the Docker image is always up-to-date with the upstream `master` branch.
- **Docker Image**: The built image is automatically pushed to this repository's GitHub Container Registry (`ghcr.io`). 

## Usage

To run the latest built image on your NAS or server, execute:

```bash
docker run -d \
  --name deepseek-harness \
  -p 3080:3080 \
  --restart unless-stopped \
  ghcr.io/foxhound1227/deepseek-harness:latest
```

## Manual Trigger

You can manually trigger a fresh build at any time by navigating to the **Actions** tab in this repository and running the `Daily Build and Publish` workflow.
