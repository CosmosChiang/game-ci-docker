ARG ubuntuImage="ubuntu:22.04"
FROM $ubuntuImage

# Fixes a Gradle crash while building for Android on Unity 2019 when there are accented characters in environment variables
ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8

# Set frontend to Noninteractive in Debian configuration.
# https://github.com/phusion/baseimage-docker/issues/58#issuecomment-47995343
RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections

# Global dependencies and toolbox in single layer
RUN apt-get -q update \
  && apt-get -q install -y --no-install-recommends apt-utils \
  && apt-get -q install -y --no-install-recommends --allow-downgrades \
  ca-certificates \
  libasound2 \
  libc6-dev \
  libcap2 \
  libgconf-2-4 \
  libglu1 \
  libgtk-3-0 \
  libncurses5 \
  libnotify4 \
  libnss3 \
  libxtst6 \
  libxss1 \
  cpio \
  lsb-release \
  xvfb \
  xz-utils \
  # Toolbox packages
  atop \
  curl \
  git \
  git-lfs \
  jq \
  openssh-client \
  wget \
  zip \
  unzip \
  lftp \
  rsync \
  # libstdc++6 upgrade
  libstdc++6 \
  && git lfs install --system --skip-repo \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* \
  && rm -rf /usr/share/icons/* \
  && rm -rf /usr/lib/python3.10/__pycache__/* \
  # Fix "No useable version of libssl" for Ubuntu 22.04
  && wget http://security.ubuntu.com/ubuntu/pool/main/o/openssl/libssl1.1_1.1.1f-1ubuntu2_amd64.deb \
  && dpkg -i libssl1.1_1.1.1f-1ubuntu2_amd64.deb \
  && rm libssl1.1_1.1.1f-1ubuntu2_amd64.deb

# Multi-platform build dependencies (consolidated for size optimization)
ARG INSTALL_WINE="true"
ARG INSTALL_IOS_TOOLS="true"
RUN apt-get -q update \
  && apt-get -q install -y --no-install-recommends --allow-downgrades \
  # Essential build tools
  build-essential \
  clang \
  lld \
  python3 \
  python3-setuptools \
  ffmpeg \
  && if [ "$INSTALL_WINE" = "true" ]; then \
  echo "Installing Wine..." && \
  # Add Wine repository for better compatibility
  apt-get -q install -y --no-install-recommends software-properties-common && \
  dpkg --add-architecture i386 && \
  apt-get -q update && \
  apt-get -q install -y --no-install-recommends wine wine64 winbind; \
  fi \
  && if [ "$INSTALL_IOS_TOOLS" = "true" ]; then \
  apt-get -q install -y --no-install-recommends cmake libxml2-dev libssl-dev; \
  fi \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* \
  && rm -rf /tmp/.wine-* || true# Disable default sound card, which removes ALSA warnings
RUN /bin/echo -e 'pcm.!default {\n\
  type plug\n\
  slave.pcm "null"\n\
  }' > /etc/asound.conf

# Support forward compatibility for unity activation
RUN echo "576562626572264761624c65526f7578" > /etc/machine-id && mkdir -p /var/lib/dbus/ && ln -sf /etc/machine-id /var/lib/dbus/machine-id

# Used by Unity editor in "modules.json" and must not end with a slash.
ENV UNITY_PATH="/opt/unity"

# Environment variables for multi-platform support
ENV ANDROID_SDK_ROOT="/opt/android-sdk"
ENV ANDROID_HOME="${ANDROID_SDK_ROOT}"
ENV ANDROID_NDK_HOME="${ANDROID_SDK_ROOT}/ndk"
ENV JAVA_HOME="/opt/java"
ENV WINEPREFIX="/opt/wine"
ENV IOS_TOOLCHAIN_PATH="/opt/ios-toolchain"

# Create directories for platform tools
RUN mkdir -p ${ANDROID_SDK_ROOT} \
  && mkdir -p ${JAVA_HOME} \
  && mkdir -p ${WINEPREFIX} \
  && mkdir -p ${IOS_TOOLCHAIN_PATH}
