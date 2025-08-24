# GameCI Multi-Platform Hub Image

## `unityci/multi-platform-hub`

Unity Hub image for multi-platform builds supporting Windows, Android, and iOS.

## Usage

Install Unity Editor versions with multi-platform modules:

```bash
docker run -it --rm unityci/multi-platform-hub:[tag] bash
```

Install Unity Editor with all supported modules:

```bash
unity-hub install --version 2022.3.0f1 --changeset 52de8fd3ce
unity-hub install-modules --version 2022.3.0f1 --module android --module ios --module windows-il2cpp
```

## Supported Platforms

- **Android**: Full Android SDK and NDK support
- **iOS**: Cross-compilation toolchain for iOS builds
- **Windows**: Wine64 for Windows IL2CPP builds

## License

[MIT license](https://github.com/game-ci/docker/blob/main/LICENSE)
