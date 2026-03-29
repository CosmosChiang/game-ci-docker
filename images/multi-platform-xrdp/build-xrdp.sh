#!/bin/bash

# Multi-Platform Unity Docker Image Build Script with XRDP Support for Linux/macOS
# Usage: ./build-xrdp.sh [UnityVersion] [UnityChangeset] [TagSuffix]

# Get script directory to handle relative paths correctly
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

UNITY_VERSION=${1:-"2022.3.0f1"}
UNITY_CHANGESET=${2:-"52de8fd3ce"}
TAG_SUFFIX=${3:-"1.0.0"}
UNITY_MODULES=${4:-"android-ios-windows"}

# Build arguments
BASE_IMAGE_TAG="unityci/multi-platform-xrdp-base:$TAG_SUFFIX"
HUB_IMAGE_TAG="unityci/multi-platform-xrdp-hub:$TAG_SUFFIX"
EDITOR_IMAGE_TAG="unityci/multi-platform-xrdp-editor:ubuntu-$UNITY_VERSION-$UNITY_MODULES-$TAG_SUFFIX"

echo "Building Multi-Platform Unity Docker Images with XRDP Support..."
echo "Unity Version: $UNITY_VERSION"
echo "Unity Changeset: $UNITY_CHANGESET"
echo "Tag Suffix: $TAG_SUFFIX"
echo "Unity Modules: $UNITY_MODULES"
echo ""

set -e

# Build base image with XRDP support
echo "Building base image with XRDP: $BASE_IMAGE_TAG"
docker build \
  -t "$BASE_IMAGE_TAG" \
  --build-arg INSTALL_WINE="true" \
  --build-arg INSTALL_IOS_TOOLS="true" \
  -f "$SCRIPT_DIR/base/Dockerfile" \
  "$SCRIPT_DIR/base/"

echo "Base image with XRDP built successfully!"
echo ""

# Build hub image
echo "Building hub image with GUI support: $HUB_IMAGE_TAG"
docker build \
  -t "$HUB_IMAGE_TAG" \
  --build-arg baseImage="$BASE_IMAGE_TAG" \
  -f "$SCRIPT_DIR/hub/Dockerfile" \
  "$SCRIPT_DIR/hub/"

echo "Hub image with GUI support built successfully!"
echo ""

# Build editor image
echo "Building editor image with XRDP: $EDITOR_IMAGE_TAG"
docker build \
  -t "$EDITOR_IMAGE_TAG" \
  --build-arg hubImage="$HUB_IMAGE_TAG" \
  --build-arg baseImage="$BASE_IMAGE_TAG" \
  --build-arg version="$UNITY_VERSION" \
  --build-arg changeSet="$UNITY_CHANGESET" \
  --build-arg module="$UNITY_MODULES" \
  -f "$SCRIPT_DIR/editor/Dockerfile" \
  "$SCRIPT_DIR/editor/"

echo "Editor image with XRDP built successfully!"
echo ""

echo "All images built successfully!"
echo "Available images:"
echo "  Base: $BASE_IMAGE_TAG"
echo "  Hub: $HUB_IMAGE_TAG"
echo "  Editor: $EDITOR_IMAGE_TAG"
echo ""
echo "Usage examples:"
echo "  # Start container with XRDP access"
echo "  docker run -d -p 3389:3389 --name unity-desktop $EDITOR_IMAGE_TAG"
echo ""
echo "  # Connect via Remote Desktop"
echo "  # Server: localhost:3389"
echo "  # Username: unity"
echo "  # Password: unity123"
echo ""
echo "  # Headless CI/CD usage"
echo "  docker run -it --rm $EDITOR_IMAGE_TAG unity-multiplatform-build android /project /build"
echo ""
echo "  # Mount project and build volumes"
echo "  docker run -d -p 3389:3389 -v \"\$PWD/project:/project\" -v \"\$PWD/build:/build\" --name unity-desktop $EDITOR_IMAGE_TAG"
