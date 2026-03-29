# GameCI Multi-Platform XRDP Base Image

## `unityci/multi-platform-xrdp-base`

Base image used to produce XRDP-enabled multi-platform Unity images supporting Windows, Android, and iOS builds.

This base image includes all dependencies from the `multi-platform` base image plus remote desktop services.

## Features

- Unity Editor base dependencies
- Wine64 for Windows IL2CPP builds
- Android SDK and NDK support
- iOS cross-compilation toolchain
- Build tools (clang, lld, cmake)
- Audio support via ffmpeg
- Git LFS support
- Common transfer and sync tools (`lftp`, `rsync`, `curl`, `zip`)
- XFCE desktop environment and XRDP service
- Default desktop user (`unity`)

## Usage

```bash
docker build -t unityci/multi-platform-xrdp-base .
docker run -d -p 3389:3389 --name unity-desktop unityci/multi-platform-xrdp-base
```

Remote desktop credentials:

- Username: `unity`
- Password: `unity123`

## License

[MIT license](https://github.com/game-ci/docker/blob/main/LICENSE)
