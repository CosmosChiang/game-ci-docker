# Unity Multi-Platform Editor Image

## `unityci/multi-platform-editor`

Unity Editor image with integrated support for Windows, Android, and iOS builds.

## Usage

Run the editor image using an interactive shell:

```bash
docker run -it --rm unityci/multi-platform-editor:[tag] bash
```

Example with specific version:

```bash
docker run -it --rm unityci/multi-platform-editor:ubuntu-2022.3.0f1-android-ios-windows-1.0.0 bash
```

## Building for Different Platforms

### Using the Unity Editor directly

```bash
# Android build
unity-editor -buildTarget Android -projectPath /project -buildPath /build/android

# iOS build  
unity-editor -buildTarget iOS -projectPath /project -buildPath /build/ios

# Windows build
unity-editor -buildTarget Win64 -projectPath /project -buildPath /build/windows

# Linux build
unity-editor -buildTarget Linux64 -projectPath /project -buildPath /build/linux
```

### Using the multi-platform build script

```bash
# Build for Android
unity-multiplatform-build android /project /build/android

# Build for iOS
unity-multiplatform-build ios /project /build/ios

# Build for Windows
unity-multiplatform-build windows /project /build/windows

# Build for Linux
unity-multiplatform-build linux /project /build/linux
```

## Platform Support

### Android Platform

- Full Android SDK and NDK integration
- Automatic license acceptance
- Java runtime environment
- Command-line tools support for Unity 2021+
- Symlink fixes for Unity 2022.2+

### iOS Platform

- iOS SDK integration
- Cross-compilation toolchain
- Xcode tools simulation via Wine (limited)

### Windows Platform

- Wine64 for Windows IL2CPP builds
- Windows Standalone Support
- Cross-compilation from Linux

### Linux Platform

- Native Linux builds
- IL2CPP support with clang/lld

## Environment Variables

The following environment variables are automatically configured:

### Android Environment

- `ANDROID_SDK_ROOT`: Android SDK location
- `ANDROID_HOME`: Android SDK home (alias)
- `ANDROID_NDK_HOME`: Android NDK location
- `JAVA_HOME`: Java runtime location
- `ANDROID_CMDLINE_TOOLS_PATH`: Command-line tools path

### iOS Environment

- `IOS_TOOLCHAIN_PATH`: iOS toolchain location
- `IOS_SDK_PATH`: iOS SDK location

### Windows Environment

- `WINEPREFIX`: Wine prefix location
- `WINEARCH`: Wine architecture (win64)
- `WINDOWS_TOOLCHAIN_PATH`: Windows toolchain location

## Notes

- The image automatically detects which platforms are installed based on the module parameter
- Platform-specific environment setup is loaded automatically when using the unity-editor command
- All builds are performed in headless mode using xvfb-run
- ⚠️ The `help` command currently does not work, but other Unity commands function properly

## License

[MIT license](https://github.com/game-ci/docker/blob/main/LICENSE)
