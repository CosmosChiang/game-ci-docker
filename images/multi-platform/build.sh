#!/bin/bash

# Multi-Platform Unity Docker Image Build Script
# Usage: ./build.sh [version] [changeset] [tag-suffix]

set -e

# Default values
UNITY_VERSION=${1:-"2020.1.6f1"}
UNITY_CHANGESET=${2:-"fc477ca6df10"}
TAG_SUFFIX=${3:-"1.0.0"}

# Build arguments
BASE_IMAGE_TAG="unityci/multi-platform-base:${TAG_SUFFIX}"
HUB_IMAGE_TAG="unityci/multi-platform-hub:${TAG_SUFFIX}"
EDITOR_IMAGE_TAG="unityci/multi-platform-editor:ubuntu-${UNITY_VERSION}-android-ios-windows-${TAG_SUFFIX}"

echo "Building Multi-Platform Unity Docker Images..."
echo "Unity Version: ${UNITY_VERSION}"
echo "Unity Changeset: ${UNITY_CHANGESET}"
echo "Tag Suffix: ${TAG_SUFFIX}"
echo ""

# Build base image
echo "Building base image: ${BASE_IMAGE_TAG}"
docker build \
  -t "${BASE_IMAGE_TAG}" \
  --build-arg INSTALL_WINE="true" \
  --build-arg INSTALL_IOS_TOOLS="true" \
  -f images/multi-platform/base/Dockerfile \
  images/multi-platform/base/

echo "Base image built successfully!"
echo ""

# Build hub image
echo "Building hub image: ${HUB_IMAGE_TAG}"
docker build \
  -t "${HUB_IMAGE_TAG}" \
  --build-arg baseImage="${BASE_IMAGE_TAG}" \
  -f images/multi-platform/hub/Dockerfile \
  images/multi-platform/hub/

echo "Hub image built successfully!"
echo ""

# Build editor image
echo "Building editor image: ${EDITOR_IMAGE_TAG}"
docker build \
  -t "${EDITOR_IMAGE_TAG}" \
  --build-arg hubImage="${HUB_IMAGE_TAG}" \
  --build-arg baseImage="${BASE_IMAGE_TAG}" \
  --build-arg version="${UNITY_VERSION}" \
  --build-arg changeSet="${UNITY_CHANGESET}" \
  --build-arg module="android-ios-windows" \
  -f images/multi-platform/editor/Dockerfile \
  images/multi-platform/editor/

echo "Editor image built successfully!"
echo ""

echo "All images built successfully!"
echo "Available images:"
echo "  Base: ${BASE_IMAGE_TAG}"
echo "  Hub: ${HUB_IMAGE_TAG}"
echo "  Editor: ${EDITOR_IMAGE_TAG}"
echo ""
echo "Usage examples:"
echo "  docker run -it --rm ${EDITOR_IMAGE_TAG} bash"
echo "  docker run -it --rm ${EDITOR_IMAGE_TAG} unity-multiplatform-build android /project /build"
