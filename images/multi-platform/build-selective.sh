#!/bin/bash

# Selective Multi-Platform Build Script
# Usage: ./build-selective.sh [platforms] [unity-version] [changeset] [tag]
# Example: ./build-selective.sh "android,ios" 2020.1.6f1 fc477ca6df10 slim

set -e

# Parse arguments
PLATFORMS=${1:-"android,ios,windows"}
UNITY_VERSION=${2:-"2020.1.6f1"}
UNITY_CHANGESET=${3:-"fc477ca6df10"}
TAG_SUFFIX=${4:-"slim"}

# Convert platforms to array
IFS=',' read -ra PLATFORM_ARRAY <<< "$PLATFORMS"

echo "🚀 Building Selective Multi-Platform Unity Docker Images"
echo "======================================================="
echo "Platforms: $PLATFORMS"
echo "Unity Version: $UNITY_VERSION"
echo "Unity Changeset: $UNITY_CHANGESET"
echo "Tag Suffix: $TAG_SUFFIX"
echo ""

# Determine which components to enable
ENABLE_ANDROID="false"
ENABLE_IOS="false"
ENABLE_WINDOWS="false"

for platform in "${PLATFORM_ARRAY[@]}"; do
  case $platform in
    android)
      ENABLE_ANDROID="true"
      echo "✅ Android support enabled"
      ;;
    ios)
      ENABLE_IOS="true"
      echo "✅ iOS support enabled"
      ;;
    windows)
      ENABLE_WINDOWS="true"
      echo "✅ Windows support enabled"
      ;;
    *)
      echo "⚠️  Unknown platform: $platform"
      ;;
  esac
done

echo ""

# Build tags
PLATFORM_TAG=$(echo "$PLATFORMS" | tr ',' '-')
BASE_IMAGE_TAG="unityci/multi-platform-base:${PLATFORM_TAG}-${TAG_SUFFIX}"
HUB_IMAGE_TAG="unityci/multi-platform-hub:${PLATFORM_TAG}-${TAG_SUFFIX}"
EDITOR_IMAGE_TAG="unityci/multi-platform-editor:ubuntu-${UNITY_VERSION}-${PLATFORM_TAG}-${TAG_SUFFIX}"

# Build base image with selective components
echo "🔨 Building selective base image: ${BASE_IMAGE_TAG}"
docker build \
  -t "${BASE_IMAGE_TAG}" \
  --build-arg ENABLE_ANDROID="$ENABLE_ANDROID" \
  --build-arg ENABLE_IOS="$ENABLE_IOS" \
  --build-arg ENABLE_WINDOWS="$ENABLE_WINDOWS" \
  -f base/Dockerfile.slim \
  base/

echo "✅ Base image built successfully!"
echo ""

# Build hub image
echo "🔨 Building hub image: ${HUB_IMAGE_TAG}"
docker build \
  -t "${HUB_IMAGE_TAG}" \
  --build-arg baseImage="${BASE_IMAGE_TAG}" \
  -f hub/Dockerfile \
  hub/

echo "✅ Hub image built successfully!"
echo ""

# Build editor image with only selected modules
MODULE_STRING=$(echo "$PLATFORMS" | tr ',' '-')
echo "🔨 Building editor image: ${EDITOR_IMAGE_TAG}"
docker build \
  -t "${EDITOR_IMAGE_TAG}" \
  --build-arg hubImage="${HUB_IMAGE_TAG}" \
  --build-arg baseImage="${BASE_IMAGE_TAG}" \
  --build-arg version="${UNITY_VERSION}" \
  --build-arg changeSet="${UNITY_CHANGESET}" \
  --build-arg module="${MODULE_STRING}" \
  -f editor/Dockerfile \
  editor/

echo "✅ Editor image built successfully!"
echo ""

# Analyze sizes
echo "📊 Image Size Analysis:"
echo "----------------------"
docker images | grep "$TAG_SUFFIX" | head -10

echo ""
echo "🎉 Selective build completed!"
echo "Available images:"
echo "  Base: ${BASE_IMAGE_TAG}"
echo "  Hub: ${HUB_IMAGE_TAG}"
echo "  Editor: ${EDITOR_IMAGE_TAG}"
echo ""
echo "💡 Usage examples:"
echo "  docker run -it --rm ${EDITOR_IMAGE_TAG} bash"
echo "  ./analyze-size.sh ${EDITOR_IMAGE_TAG}"
