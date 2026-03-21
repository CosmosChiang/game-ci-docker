# GameCI Multi-Platform Base Image

## `unityci/multi-platform-base`

Base image used to produce multi-platform Unity images supporting Windows, Android, and iOS builds.

This base image includes all necessary dependencies for:

- **Windows builds**: Wine64 and Windows IL2CPP support
- **Android builds**: Android SDK, NDK, and Java runtime
- **iOS builds**: iOS toolchain and cross-compilation tools

Not intended for external use per se. Use the hub and editor images built from this base.

## Features

- Unity Editor base dependencies
- Wine64 for Windows IL2CPP builds
- Android SDK and NDK support
- iOS cross-compilation toolchain
- Build tools (clang, lld, cmake)
- Audio support via ffmpeg
- Git LFS support
- Common transfer and sync tools (`lftp`, `rsync`, `curl`, `zip`)

## License

[MIT license](https://github.com/game-ci/docker/blob/main/LICENSE)
