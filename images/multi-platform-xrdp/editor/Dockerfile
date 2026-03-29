ARG hubImage="unityci/multi-platform-xrdp-hub"
ARG baseImage="unityci/multi-platform-xrdp-base"

###########################
#         Builder         #
###########################

FROM $hubImage AS builder

# Install editor
ARG version
ARG changeSet
RUN unity-hub install --version "$version" --changeset "$changeSet" | tee /var/log/install-editor.log && grep 'Failed to install\|Error while installing an editor\|Completed with errors' /var/log/install-editor.log | exit $(wc -l)

# Install modules for that editor - multi-platform modules with version-aware module selection
ARG module="android-ios-windows"
RUN for mod in $(echo $module | tr '-' ' '); do \
  if [ "$mod" = "base" ] ; then \
  echo "running default modules for this baseOs"; \
  elif [ "$mod" = "android" ] ; then \
  unity-hub install-modules --version "$version" --module "android" --childModules | tee /var/log/install-module-android.log && grep 'Missing module\|Completed with errors' /var/log/install-module-android.log | exit $(wc -l); \
  elif [ "$mod" = "ios" ] ; then \
  unity-hub install-modules --version "$version" --module "ios" --childModules | tee /var/log/install-module-ios.log && grep 'Missing module\|Completed with errors' /var/log/install-module-ios.log | exit $(wc -l); \
  elif [ "$mod" = "windows" ] ; then \
  echo "Installing Windows support modules for Unity $version..." && \
  # Try different Windows module names based on Unity version \
  if echo "$version" | grep -qP '^(2019|2020|2021.[0-1])'; then \
  echo "Using legacy Windows modules for Unity $version" && \
  (unity-hub install-modules --version "$version" --module "windows-mono" --childModules 2>/dev/null || \
  unity-hub install-modules --version "$version" --module "windows" --childModules 2>/dev/null || \
  echo "Windows modules not available for Unity $version, continuing without Windows support..."); \
  else \
  echo "Using modern Windows modules for Unity $version" && \
  (unity-hub install-modules --version "$version" --module "windows-il2cpp" --childModules 2>/dev/null || \
  unity-hub install-modules --version "$version" --module "windows-mono" --childModules 2>/dev/null || \
  echo "Windows modules not available for Unity $version, continuing without Windows support..."); \
  fi | tee /var/log/install-module-windows.log; \
  else \
  unity-hub install-modules --version "$version" --module "$mod" --childModules | tee /var/log/install-module-${mod}.log && grep 'Missing module\|Completed with errors' /var/log/install-module-${mod}.log | exit $(wc -l); \
  fi \
  done \
  # Set execute permissions for modules
  && chmod -R 755 /opt/unity/editors/$version/Editor/Data/PlaybackEngines

# Always install linux-server for Linux builds
RUN echo "$version-$module" | grep -q -vP '^(2021.2.(?![0-4](?![0-9]))|2021.[3-9]|202[2-9]|[6-9][0-9]{3}|[1-9][0-9]{4,}).*' \
  && exit 0 \
  || unity-hub install-modules --version "$version" --module "linux-server" --childModules | tee /var/log/install-module-linux-server.log && grep 'Missing module' /var/log/install-module-linux-server.log | exit $(wc -l);

# Always install windows-server for Windows builds
RUN echo "$version-$module" | grep -q -vP '^(2021.2.(?![0-4](?![0-9]))|2021.[3-9]|202[2-9]|[6-9][0-9]{3}|[1-9][0-9]{4,}).*' \
  && exit 0 \
  || unity-hub install-modules --version "$version" --module "windows-server" --childModules | tee /var/log/install-module-windows-server.log && grep 'Missing module' /var/log/install-module-windows-server.log | exit $(wc -l);

###########################
#       Unity Editor      #
###########################

FROM $baseImage

# Copy Unity Editor from builder
ARG version
ARG changeSet
ARG RBENV_RELEASE="v1.3.2"
ARG RUBY_BUILD_VERSION="v20260317"
ARG RUBY_VERSION="4.0.2"
ARG COCOAPODS_VERSION="1.16.2"
COPY --from=builder "$UNITY_PATH/" "$UNITY_PATH/"

# Add a file containing the version for this build
RUN echo $version > "$UNITY_PATH/version"

# Unity Hub installs editors to $UNITY_PATH/editors/{version}/, but all scripts
# reference $UNITY_PATH/Editor/. Create compatibility symlinks so both paths work.
RUN ln -sfn "${UNITY_PATH}/editors/${version}/Editor" "${UNITY_PATH}/Editor" \
  && ln -sf "${UNITY_PATH}/editors/${version}/modules.json" "${UNITY_PATH}/modules.json"

###########################
#   iOS Ruby Toolchain    #
###########################

ENV RBENV_ROOT="/opt/rbenv"
ENV PATH="${RBENV_ROOT}/bin:${RBENV_ROOT}/shims:${PATH}"

# Install pinned rbenv, Ruby and CocoaPods for iOS workflows.
RUN apt-get -q update \
  && apt-get -q install -y --no-install-recommends \
  libssl-dev \
  libreadline-dev \
  zlib1g-dev \
  libyaml-dev \
  libffi-dev \
  libgdbm-dev \
  libncurses5-dev \
  libdb-dev \
  uuid-dev \
  autoconf \
  bison \
  libtool \
  pkg-config \
  && git clone --branch "$RBENV_RELEASE" --depth 1 https://github.com/rbenv/rbenv.git "$RBENV_ROOT" \
  && mkdir -p "$RBENV_ROOT/plugins" \
  && git clone --branch "$RUBY_BUILD_VERSION" --depth 1 https://github.com/rbenv/ruby-build.git "$RBENV_ROOT/plugins/ruby-build" \
  && "$RBENV_ROOT/bin/rbenv" install "$RUBY_VERSION" \
  && "$RBENV_ROOT/bin/rbenv" global "$RUBY_VERSION" \
  && "$RBENV_ROOT/bin/rbenv" rehash \
  && gem install --no-document cocoapods -v "$COCOAPODS_VERSION" \
  && "$RBENV_ROOT/bin/rbenv" rehash \
  && ruby --version \
  && rbenv --version \
  && pod --version --allow-root \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

# [Modules] Allow modules to be symlinked
# Re-configure path resolver for Unity modules.json
RUN if [ -f "$UNITY_PATH/modules.json" ]; then \
  jq --arg path "$UNITY_PATH" '. |= map(if .destination and (.destination | contains("*")) then .destination = "\($path)/Editor/Data/PlaybackEngines/" + (.destination | split("/")[-1]) else . end)' /opt/unity/modules.json > /tmp/modules.json \
  && cat /tmp/modules.json > "$UNITY_PATH/modules.json" \
  && rm /tmp/modules.json; \
  fi

# [Modules] Create symbolink links
# shellcheck disable=SC2016
RUN jq -r '.[] | .destination + " " + .renameTo' "$UNITY_PATH/modules.json" 2>/dev/null | grep '^/' | while read src dst; do echo "Linking $src to $dst"; mkdir -p "$(dirname "$dst")"; ln -sf "$src" "$dst"; done; exit 0

# Alias to "unity-editor" with default params, will start headless
ARG module="android-ios-windows"
# Add default module include to the unity-editor
RUN mkdir -p /usr/bin/unity-editor.d \
  && printf '#!/bin/bash\nset -x\nsource /usr/bin/unity-editor.d/android-setup.sh 2>/dev/null || true\nsource /usr/bin/unity-editor.d/ios-setup.sh 2>/dev/null || true\nsource /usr/bin/unity-editor.d/windows-setup.sh 2>/dev/null || true\n\nxvfb-run -ae /dev/stdout "%s/Editor/Unity" -batchmode "$@"\n' "${UNITY_PATH}" \
  > /usr/bin/unity-editor \
  && chmod +x /usr/bin/unity-editor

# Create GUI Unity Editor launcher for desktop environment
RUN printf '#!/bin/bash\nsource /usr/bin/unity-editor.d/android-setup.sh 2>/dev/null || true\nsource /usr/bin/unity-editor.d/ios-setup.sh 2>/dev/null || true\nsource /usr/bin/unity-editor.d/windows-setup.sh 2>/dev/null || true\n[ -z "$DISPLAY" ] && export DISPLAY=:10.0\nexec "%s/Editor/Unity" "$@"\n' "${UNITY_PATH}" \
  > /usr/bin/unity-editor-gui \
  && chmod +x /usr/bin/unity-editor-gui

# Create desktop shortcut for Unity Editor
# Icon: LargeUnityIcon.png ships with every Unity editor installation
# The file is marked executable so XFCE recognises it as an application launcher;
# a companion autostart entry (trust-desktop.desktop) marks it as GIO-trusted
# so XFCE 4.14+ renders the real icon instead of a generic document placeholder.
RUN mkdir -p /home/unity/Desktop \
  && printf '[Desktop Entry]\nVersion=1.0\nType=Application\nName=Unity Editor %s\nComment=Unity Editor with Multi-Platform Support\nExec=/usr/bin/unity-editor-gui\nIcon=%s/Editor/Data/Resources/LargeUnityIcon.png\nTerminal=false\nStartupNotify=false\nCategories=Development;\n' \
  "${version}" "${UNITY_PATH}" \
  > /home/unity/Desktop/unity-editor.desktop \
  && chmod +x /home/unity/Desktop/unity-editor.desktop \
  && chown unity:unity /home/unity/Desktop/unity-editor.desktop \
  # Add autostart entry to GIO-trust all desktop shortcuts once the session starts
  && su - unity -c 'mkdir -p /home/unity/.config/autostart' \
  && printf '[Desktop Entry]\nType=Application\nName=Trust Desktop Shortcuts\nExec=bash -c "sleep 3 && gio set /home/unity/Desktop/unity-editor.desktop metadata::trusted true && gio set /home/unity/Desktop/unity-hub.desktop metadata::trusted true"\nHidden=false\nNoDisplay=true\nX-GNOME-Autostart-enabled=true\n' \
  > /home/unity/.config/autostart/trust-desktop.desktop \
  && chmod +x /home/unity/.config/autostart/trust-desktop.desktop \
  && chown unity:unity /home/unity/.config/autostart/trust-desktop.desktop

###########################
#     Platform Setup      #
###########################

#=======================================================================================
# [Android] Setup Android SDK path and environment variables
#=======================================================================================
RUN echo "$module" | grep -q -v 'android' \
  && exit 0 \
  || : \
  && export RAW_ANDROID_SDK_ROOT=$(jq -cr '(.[] | select(.id | contains("android-sdk-platform-tools"))).destination' $UNITY_PATH/modules.json 2>/dev/null || echo "${UNITY_PATH}/Editor/Data/PlaybackEngines/AndroidPlayer/SDK") \
  && export ESCAPED_UNITY_PATH=$(printf '%s' "$UNITY_PATH" | sed 's/[#\/]/\\\0/g') \
  && export ANDROID_SDK_ROOT=$(echo $RAW_ANDROID_SDK_ROOT | sed -e "s/{UNITY_PATH}/$ESCAPED_UNITY_PATH/g") \
  && export ANDROID_HOME=${ANDROID_SDK_ROOT} \
  && export RAW_ANDROID_NDK_ROOT=$(jq -cr '(.[] | select(.id | contains("android-ndk"))).destination' $UNITY_PATH/modules.json 2>/dev/null || echo "${UNITY_PATH}/Editor/Data/PlaybackEngines/AndroidPlayer/NDK") \
  && export ANDROID_NDK_HOME=$(echo $RAW_ANDROID_NDK_ROOT | sed -e "s/{UNITY_PATH}/$ESCAPED_UNITY_PATH/g") \
  && export RAW_JAVA_HOME=$(jq -cr '(.[] | select(.id | contains("android-open-jdk"))).destination' $UNITY_PATH/modules.json 2>/dev/null || echo "${UNITY_PATH}/Editor/Data/PlaybackEngines/AndroidPlayer/Tools/OpenJDK/Linux") \
  && export JAVA_HOME=$(echo $RAW_JAVA_HOME | sed -e "s/{UNITY_PATH}/$ESCAPED_UNITY_PATH/g") \
  && export RAW_CMDLINE_TOOLS_PATH=$(jq -cr '(.[] | select(.id | contains("android-sdk-command-line-tools"))).renameTo' $UNITY_PATH/modules.json 2>/dev/null || echo "") \
  && export ANDROID_CMDLINE_TOOLS_PATH=$(echo $RAW_CMDLINE_TOOLS_PATH | sed -e "s/{UNITY_PATH}/$ESCAPED_UNITY_PATH/g") \
  && export PATH=${JAVA_HOME}/bin:${ANDROID_CMDLINE_TOOLS_PATH}/bin:${ANDROID_SDK_ROOT}/tools:${ANDROID_SDK_ROOT}/tools/bin:${ANDROID_SDK_ROOT}/platform-tools:${PATH} \
  \
  # Update alias 'unity-editor'
  && { \
  echo "export ANDROID_SDK_ROOT=${ANDROID_SDK_ROOT}"; \
  echo "export ANDROID_HOME=${ANDROID_HOME}"; \
  echo "export ANDROID_NDK_HOME=${ANDROID_NDK_HOME}"; \
  echo "export JAVA_HOME=${JAVA_HOME}"; \
  echo "export ANDROID_CMDLINE_TOOLS_PATH=${ANDROID_CMDLINE_TOOLS_PATH}"; \
  echo "export PATH=${PATH}"; \
  } > /usr/bin/unity-editor.d/android-setup.sh \
  # Update '~/.bashrc' to enable using variables when logging in
  && echo ". /usr/bin/unity-editor.d/android-setup.sh" >> ~/.bashrc

#=======================================================================================
# [Android] Accept Android SDK licenses
#=======================================================================================
RUN echo "$module" | grep -q -v 'android' \
  && exit 0 \
  || : \
  && . ~/.bashrc \
  && if [ -f "${ANDROID_CMDLINE_TOOLS_PATH}/bin/sdkmanager" ]; then \
  yes | "${ANDROID_CMDLINE_TOOLS_PATH}/bin/sdkmanager" --licenses; \
  elif [ -f "${ANDROID_HOME}/tools/bin/sdkmanager" ]; then \
  yes | "${ANDROID_HOME}/tools/bin/sdkmanager" --licenses; \
  fi

#=======================================================================================
# [Android 2022.x+] Fix for symlink issue
#=======================================================================================
RUN echo "$version-$module" | grep -q -vP '^(2022.[2-9]|202[3-9]|20[3-9]).*android' \
  && exit 0 \
  || : \
  && . ~/.bashrc \
  && if [ -d "${ANDROID_NDK_HOME}/toolchains/llvm/prebuilt/linux-x86_64/bin" ]; then \
  cd "${ANDROID_NDK_HOME}/toolchains/llvm/prebuilt/linux-x86_64/bin" \
  && for f in $(find . -type f -size -64c); do \
  target=$(cat $f) && echo "Making symlink $f -> $target" && rm $f && ln -s $target $f; \
  done; \
  fi

#=======================================================================================
# [iOS] Setup iOS build environment
#=======================================================================================
RUN echo "$module" | grep -q -v 'ios' \
  && exit 0 \
  || : \
  # Environment Variables for iOS
  && export IOS_TOOLCHAIN_PATH="/opt/ios-toolchain" \
  && export IOS_SDK_PATH="${UNITY_PATH}/Editor/Data/PlaybackEngines/iOSSupport" \
  \
  # Update alias 'unity-editor'
  && { \
  echo "export IOS_TOOLCHAIN_PATH=${IOS_TOOLCHAIN_PATH}"; \
  echo "export IOS_SDK_PATH=${IOS_SDK_PATH}"; \
  } > /usr/bin/unity-editor.d/ios-setup.sh \
  # Update '~/.bashrc' to enable using variables when logging in
  && echo ". /usr/bin/unity-editor.d/ios-setup.sh" >> ~/.bashrc

#=======================================================================================
# [Windows] Setup Windows build environment with Wine - version aware
#=======================================================================================
RUN echo "$module" | grep -q -v 'windows' \
  && exit 0 \
  || : \
  # Environment Variables for Windows builds
  && export WINEPREFIX="/opt/wine" \
  && export WINEARCH="win64" \
  # Check for different Windows toolchain paths based on Unity version \
  && if [ -d "${UNITY_PATH}/Editor/Data/PlaybackEngines/WindowsStandaloneSupport" ]; then \
  export WINDOWS_TOOLCHAIN_PATH="${UNITY_PATH}/Editor/Data/PlaybackEngines/WindowsStandaloneSupport"; \
  elif [ -d "${UNITY_PATH}/Editor/Data/PlaybackEngines/windowsstandalonesupport" ]; then \
  export WINDOWS_TOOLCHAIN_PATH="${UNITY_PATH}/Editor/Data/PlaybackEngines/windowsstandalonesupport"; \
  else \
  echo "Windows toolchain not found, setting default path" && \
  export WINDOWS_TOOLCHAIN_PATH="${UNITY_PATH}/Editor/Data/PlaybackEngines/WindowsStandaloneSupport"; \
  fi \
  \
  # Initialize Wine (only if Wine is actually installed and available)
  && if command -v wineboot >/dev/null 2>&1; then \
  echo "Wine found, initializing for Windows builds..." && \
  wineboot --init 2>/dev/null || echo "Wine initialization failed, continuing anyway"; \
  else \
  echo "Wine not found, skipping Windows Wine initialization"; \
  fi \
  \
  # Update alias 'unity-editor'
  && { \
  echo "export WINEPREFIX=${WINEPREFIX}"; \
  echo "export WINEARCH=${WINEARCH}"; \
  echo "export WINDOWS_TOOLCHAIN_PATH=${WINDOWS_TOOLCHAIN_PATH}"; \
  } > /usr/bin/unity-editor.d/windows-setup.sh \
  # Update '~/.bashrc' to enable using variables when logging in
  && echo ". /usr/bin/unity-editor.d/windows-setup.sh" >> ~/.bashrc

###########################
#       Extra steps       #
###########################

#=======================================================================================
# [2019.x] libnotify4 libunwind-dev libssl1.0.0
#=======================================================================================
RUN echo "$version" | grep -q -v '^2019.' \
  && exit 0 \
  || : \
  && apt-get -q update \
  && apt-get -q install -y --no-install-recommends --allow-downgrades \
  libnotify4 \
  libunwind-dev \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* \
  # Install libssl1.0.0
  && wget http://security.ubuntu.com/ubuntu/pool/main/o/openssl/libssl1.0.0_1.0.2g-1ubuntu4.20_amd64.deb \
  && dpkg -i libssl1.0.0_1.0.2g-1ubuntu4.20_amd64.deb \
  && rm libssl1.0.0_1.0.2g-1ubuntu4.20_amd64.deb

#=======================================================================================
# [2018.x/2019.x/2020.x/2021.1.x-webgl] python2 for older Unity versions
#=======================================================================================
RUN echo "$version-$module" | grep -q -v '^\(2018\|2019\|2020\|2021.1\).*' \
  && exit 0 \
  || : \
  && apt-get -q update \
  && apt-get -q install -y --no-install-recommends --allow-downgrades \
  python-setuptools \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* \
  && ln -s /usr/bin/python2 /usr/bin/python

#=======================================================================================
# [2021.x/2022.x-mac-mono] x64arm64/x64ARM64 case issue fix
#=======================================================================================
RUN echo "$version-$module" | grep -q -v '^202[12].*' \
  && exit 0 \
  || : \
  && if [ -d "$UNITY_PATH/Editor/Data/PlaybackEngines/MacStandaloneSupport/Variations" ]; then \
  cd "$UNITY_PATH/Editor/Data/PlaybackEngines/MacStandaloneSupport/Variations" \
  && if [ -d "macos_x64arm64_player_nondevelopment_mono" ] && [ ! -d "macos_x64ARM64_player_nondevelopment_mono" ]; then \
  ln -s macos_x64arm64_player_nondevelopment_mono macos_x64ARM64_player_nondevelopment_mono; \
  fi \
  && if [ -d "macos_x64arm64_player_development_mono" ] && [ ! -d "macos_x64ARM64_player_development_mono" ]; then \
  ln -s macos_x64arm64_player_development_mono macos_x64ARM64_player_development_mono; \
  fi; \
  fi

#=======================================================================================
# Multi-platform build script
#=======================================================================================
RUN /bin/echo -e '#!/bin/bash\n\
  \n\
  # Multi-platform Unity build script\n\
  # Usage: unity-multiplatform-build [android|ios|windows|linux] [project-path] [build-path] [additional-args]\n\
  \n\
  PLATFORM=$1\n\
  PROJECT_PATH=${2:-.}\n\
  BUILD_PATH=${3:-./build}\n\
  shift 3\n\
  \n\
  case $PLATFORM in\n\
  android)\n\
  echo "Building for Android..."\n\
  . /usr/bin/unity-editor.d/android-setup.sh\n\
  unity-editor -buildTarget Android -projectPath "$PROJECT_PATH" -buildPath "$BUILD_PATH" "$@"\n\
  ;;\n\
  ios)\n\
  echo "Building for iOS..."\n\
  . /usr/bin/unity-editor.d/ios-setup.sh\n\
  unity-editor -buildTarget iOS -projectPath "$PROJECT_PATH" -buildPath "$BUILD_PATH" "$@"\n\
  ;;\n\
  windows)\n\
  echo "Building for Windows..."\n\
  . /usr/bin/unity-editor.d/windows-setup.sh\n\
  unity-editor -buildTarget Win64 -projectPath "$PROJECT_PATH" -buildPath "$BUILD_PATH" "$@"\n\
  ;;\n\
  linux)\n\
  echo "Building for Linux..."\n\
  unity-editor -buildTarget Linux64 -projectPath "$PROJECT_PATH" -buildPath "$BUILD_PATH" "$@"\n\
  ;;\n\
  *)\n\
  echo "Usage: unity-multiplatform-build [android|ios|windows|linux] [project-path] [build-path] [additional-args]"\n\
  echo "Supported platforms: android, ios, windows, linux"\n\
  exit 1\n\
  ;;\n\
  esac' > /usr/bin/unity-multiplatform-build \
  && chmod 755 /usr/bin/unity-multiplatform-build

# Copy setup script for unity user's environment
RUN cp /usr/bin/unity-editor.d/*.sh /home/unity/ 2>/dev/null || true \
  && chown unity:unity /home/unity/*.sh 2>/dev/null || true

# Add setup scripts to unity user's bashrc
RUN echo ". /usr/bin/unity-editor.d/android-setup.sh 2>/dev/null || true" >> /home/unity/.bashrc \
  && echo ". /usr/bin/unity-editor.d/ios-setup.sh 2>/dev/null || true" >> /home/unity/.bashrc \
  && echo ". /usr/bin/unity-editor.d/windows-setup.sh 2>/dev/null || true" >> /home/unity/.bashrc
