ARG baseImage="unityci/multi-platform-xrdp-base"
FROM $baseImage
ARG hubVersion="3.7.0"

# Hub dependencies and Unity Hub installation in single layer
RUN apt-get -q update \
    && apt-get -q install -y --no-install-recommends --allow-downgrades zenity libgbm1 gnupg \
    # Install Unity Hub
    && wget -qO - https://hub.unity3d.com/linux/keys/public | gpg --dearmor | tee /usr/share/keyrings/Unity_Technologies_ApS.gpg > /dev/null \
    && sh -c 'echo "deb [signed-by=/usr/share/keyrings/Unity_Technologies_ApS.gpg] https://hub.unity3d.com/linux/repos/deb stable main" > /etc/apt/sources.list.d/unityhub.list' \
    && sh -c 'echo "deb [signed-by=/usr/share/keyrings/Unity_Technologies_ApS.gpg] https://hub.unity3d.com/linux/repos/deb unstable main" > /etc/apt/sources.list.d/unityhub-beta.list' \
    && apt-get -q update \
    && apt-get -q install -y "unityhub=$hubVersion" \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /tmp/*

# Bug in xvfb-run that causes it to redirect stderr to stdout. We want it separate
RUN sed -i 's/^\(.*DISPLAY=:.*XAUTHORITY=.*\)\( "\$@" \)2>&1$/\1\2/' /usr/bin/xvfb-run

# Alias to "unity-hub" with default params for headless operation
RUN echo '#!/bin/bash\nxvfb-run -a /opt/unityhub/unityhub-bin --no-sandbox --headless "$@" 2>/dev/null' > /usr/bin/unity-hub \
    && chmod +x /usr/bin/unity-hub

# Create GUI Unity Hub launcher for desktop environment
RUN echo '#!/bin/bash\n\
    # Ensure we have a display\n\
    if [ -z "$DISPLAY" ]; then\n\
    export DISPLAY=:10.0\n\
    fi\n\
    \n\
    # Start Unity Hub in GUI mode\n\
    /opt/unityhub/unityhub-bin --no-sandbox "$@"' > /usr/bin/unity-hub-gui \
    && chmod +x /usr/bin/unity-hub-gui

# Configure
RUN mkdir -p "${UNITY_PATH}/editors" \
    && unity-hub install-path --set "${UNITY_PATH}/editors/" \
    && find /tmp -mindepth 1 -delete

# Create desktop shortcut for Unity Hub
# Icon: unityhub.png is installed into the hicolor theme by Unity Hub's deb package
RUN mkdir -p /home/unity/Desktop \
    && printf '[Desktop Entry]\nVersion=1.0\nType=Application\nName=Unity Hub\nComment=Unity Hub for managing Unity installations\nExec=/usr/bin/unity-hub-gui\nIcon=unityhub\nTerminal=false\nStartupNotify=false\nCategories=Development;\n' \
    > /home/unity/Desktop/unity-hub.desktop \
    && chmod +x /home/unity/Desktop/unity-hub.desktop \
    && chown unity:unity /home/unity/Desktop/unity-hub.desktop
