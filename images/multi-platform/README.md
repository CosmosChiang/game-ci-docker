# Multi-Platform Unity Docker Images

This directory contains Docker images that integrate Windows, Android, and iOS platform support into a single Unity Editor image.

## Overview

The multi-platform images are designed to provide a comprehensive Unity development environment that can build for multiple platforms without needing separate specialized images.

## Structure

```text
multi-platform/
├── base/                    # Base image with all platform dependencies
│   ├── Dockerfile
│   ├── README.md
│   └── 100-characters-dockerhub-description.txt
├── hub/                     # Unity Hub with multi-platform support
│   ├── Dockerfile
│   ├── README.md
│   └── 100-characters-dockerhub-description.txt
├── editor/                  # Unity Editor with integrated platform support
│   ├── Dockerfile
│   ├── README.md
│   └── 100-characters-dockerhub-description.txt
├── build.sh                 # Build script for all images
└── README.md               # This file
```

## Supported Platforms

- **Android**: Full Android SDK, NDK, and Java runtime
- **iOS**: Cross-compilation toolchain and iOS SDK
- **Windows**: Wine64 for Windows IL2CPP builds
- **Linux**: Native Linux builds with IL2CPP support

## Quick Start

### Building the Images

```bash
# Build with default Unity version (2022.3.0f1)
./build.sh

# Build with specific Unity version
./build.sh 2022.3.5f1 1e1e9322b261 1.0.0

# Build with custom tag
./build.sh 2022.3.0f1 52de8fd3ce custom-tag
```

### Using the Editor Image

```bash
# Run interactive shell
docker run -it --rm unityci/multi-platform-editor:ubuntu-2022.3.0f1-android-ios-windows-1.0.0 bash

# Build for Android
docker run --rm -v $(pwd)/project:/project -v $(pwd)/build:/build \
  unityci/multi-platform-editor:ubuntu-2022.3.0f1-android-ios-windows-1.0.0 \
  unity-multiplatform-build android /project /build

# Build for iOS
docker run --rm -v $(pwd)/project:/project -v $(pwd)/build:/build \
  unityci/multi-platform-editor:ubuntu-2022.3.0f1-android-ios-windows-1.0.0 \
  unity-multiplatform-build ios /project /build

# Build for Windows
docker run --rm -v $(pwd)/project:/project -v $(pwd)/build:/build \
  unityci/multi-platform-editor:ubuntu-2022.3.0f1-android-ios-windows-1.0.0 \
  unity-multiplatform-build windows /project /build
```

## Image Hierarchy

1. **multi-platform-base**: Base Ubuntu image with all platform dependencies
   - Wine64 for Windows builds
   - Build tools (clang, lld, cmake)
   - Audio support (ffmpeg)
  - Common CI utilities (`lftp`, `rsync`, `git`, `curl`, `zip`)
   - Platform directories pre-created

2. **multi-platform-hub**: Unity Hub with multi-platform module support
   - Based on multi-platform-base
   - Unity Hub with headless support
   - Module installation capabilities

3. **multi-platform-editor**: Unity Editor with integrated platform support
   - Based on multi-platform-base and multi-platform-hub
   - Unity Editor with all platform modules
   - Platform-specific environment configuration
  - Pinned iOS Ruby toolchain (`rbenv` `v1.3.2`, Ruby `4.0.2`, CocoaPods `1.16.2`)
   - Multi-platform build script

## Environment Variables

Each platform has its own set of environment variables that are automatically configured:

### Android Environment

- `ANDROID_SDK_ROOT`, `ANDROID_HOME`
- `ANDROID_NDK_HOME`
- `JAVA_HOME`
- `ANDROID_CMDLINE_TOOLS_PATH`

### iOS Environment

- `IOS_TOOLCHAIN_PATH`
- `IOS_SDK_PATH`

### Windows Environment

- `WINEPREFIX`
- `WINEARCH`
- `WINDOWS_TOOLCHAIN_PATH`

## Advantages over Separate Images

1. **Reduced Storage**: Single image instead of multiple platform-specific images
2. **Simplified CI/CD**: One image to manage for all platforms
3. **Consistent Environment**: Same base environment for all platforms
4. **Cross-Platform Development**: Switch between platforms without changing containers

## License

[MIT license](https://github.com/game-ci/docker/blob/main/LICENSE)
