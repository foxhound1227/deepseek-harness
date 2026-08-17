# DeepSeek Harness 自动化 Docker 构建仓库

本仓库是一个专用于官方 [DeepSeek Harness](https://github.com/deepseek-ai/deepseek-harness) 的 **Docker 自动化构建配置库**。

## 架构说明

本仓库已剥离官方源代码，单纯作为 GitHub Actions 流水线，为您自动构建并分发最新的 Docker 镜像。

- **上游自动同步**: 您**不需要**手动同步（Sync fork）官方源代码。本仓库的 GitHub Action 会在构建时，自动从 `deepseek-ai/deepseek-harness` 官方仓库拉取最新鲜的代码。
- **每日定时构建**: 每天北京时间早上 8:00（0:00 UTC），系统会自动触发一次全量构建，确保您的 Docker 镜像永远紧跟官方主分支进度。
- **镜像分发**: 编译好的镜像会自动推送到本仓库绑定的 GitHub Container Registry (`ghcr.io`) 中。

## 镜像环境特性

本镜像在官方源码基础上进行了一些自动化修复和补丁，以适配 Docker 和 NAS 局域网环境：

- **基础环境**: 基于 `node:22-bookworm-slim` 构建，额外预装了 `python3`、`make`、`g++` 和 `git`，完美满足运行与编译所需。
- **网络访问解绑**: 强制将服务绑定到 `0.0.0.0`，并永久解除了后端的 `403 Forbidden` 跨域信任限制，支持 NAS 等局域网 IP 直接访问。
- **HTTP 访问修复**: 针对非 HTTPS 局域网环境注入了 `crypto.randomUUID` Polyfill，解决了前端报错 `crypto.randomUUID is not a function` 导致页面无法加载的问题。
- **默认端口**: 暴露 Web UI 的默认端口 `3080`。

## 使用方法

在您的 NAS 服务器或 Docker 环境中，直接运行以下命令即可启动最新版本的服务：

```bash
docker run -d \
  --name deepseek-harness \
  -p 3080:3080 \
  --restart unless-stopped \
  ghcr.io/foxhound1227/deepseek-harness:latest
```

## 手动触发更新

如果您急需拉取官方的某次紧急修复，无需等待第二天早上 8 点，您可以前往本仓库的 **Actions** 标签页，找到 `Daily Build and Publish` 工作流，点击 **Run workflow** 即可随时手动触发镜像的重新打包。
