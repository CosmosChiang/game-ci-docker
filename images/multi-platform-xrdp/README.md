# Multi-Platform Unity Docker Images with XRDP Support

This directory contains Docker images that integrate Windows, Android, and iOS platform support into a single Unity Editor image with XRDP remote desktop access.

## Overview

The XRDP multi-platform images provide the same multi-platform build capabilities as `multi-platform` while adding a full XFCE desktop environment for remote GUI workflows.

## Structure

```text
multi-platform-xrdp/
├── base/                    # Base image with platform deps + XRDP desktop
│   ├── Dockerfile
│   ├── README.md
│   └── 100-characters-dockerhub-description.txt
├── hub/                     # Unity Hub with headless + GUI launchers
│   ├── Dockerfile
│   ├── README.md
│   └── 100-characters-dockerhub-description.txt
├── editor/                  # Unity Editor with integrated platform support
│   ├── Dockerfile
│   ├── README.md
│   └── 100-characters-dockerhub-description.txt
├── build-xrdp.sh            # Linux/macOS build script
├── build-xrdp.ps1           # Windows build script
└── docker-compose.yml       # Local development stack
```

## Supported Platforms

- **Android**: Full Android SDK, NDK, and Java runtime
- **iOS**: Cross-compilation toolchain and iOS SDK
- **Windows**: Wine64 for Windows IL2CPP builds
- **Linux**: Native Linux builds with IL2CPP support

## XRDP Features

- Full XFCE desktop environment via RDP
- GUI launchers for Unity Hub and Unity Editor
- Headless and GUI workflows in the same image
- Shared project/build/cache mount pattern for local development

## Quick Start

### Build images

```powershell
# Windows PowerShell
.\build-xrdp.ps1 2022.3.0f1 52de8fd3ce 1.0.0 android-ios-windows
```

```bash
# Linux/macOS
./build-xrdp.sh 2022.3.0f1 52de8fd3ce 1.0.0 android-ios-windows
```

### Run editor container with RDP

```bash
docker run -d -p 3389:3389 --name unity-desktop \
  unityci/multi-platform-xrdp-editor:ubuntu-2022.3.0f1-android-ios-windows-1.0.0
```

### Connect via Remote Desktop

- **Server**: `localhost:3389`
- **Username**: `unity`
- **Password**: `unity123`

## Docker Compose workflow

```bash
docker compose --env-file .env up -d multi-platform-xrdp-editor
```

This creates an editor service that exposes RDP and mounts:

- `${PROJECT_PATH}` to `/project`
- `${BUILD_PATH}` to `/build`
- `${CACHE_PATH}` to `/cache`

## Environment Variables

See `.env.template` for defaults.

- Build and version: `UNITY_VERSION`, `UNITY_CHANGESET`, `TAG_SUFFIX`, `UNITY_MODULES`
- Desktop and stack: `RDP_PORT`, `HUB_VERSION`, `UBUNTU_IMAGE`
- Build features: `INSTALL_WINE`, `INSTALL_IOS_TOOLS`
- Paths: `PROJECT_PATH`, `BUILD_PATH`, `CACHE_PATH`
- Optional licensing: `UNITY_USERNAME`, `UNITY_PASSWORD`, `UNITY_SERIAL`

## License

[MIT license](https://github.com/game-ci/docker/blob/main/LICENSE)
