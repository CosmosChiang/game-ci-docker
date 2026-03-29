#!/bin/bash

# Initialize machine-id for dbus
if [ ! -f /etc/machine-id ]; then
    dbus-uuidgen > /etc/machine-id
fi

# Setup .Xauthority for unity user
su - unity -c "touch /home/unity/.Xauthority"

# Generate xrdp keys if they don't exist
if [ ! -f /etc/xrdp/rsakeys.ini ]; then
    xrdp-keygen xrdp /etc/xrdp/rsakeys.ini
fi

# Start dbus
mkdir -p /var/run/dbus
dbus-daemon --system --fork

# Start xrdp services
/usr/sbin/xrdp-sesman
/usr/sbin/xrdp --nodaemon

echo "XRDP Desktop services started. Connect to port 3389 with user 'unity' and password 'unity123'"
