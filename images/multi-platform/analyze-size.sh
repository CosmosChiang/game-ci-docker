#!/bin/bash

# Docker Image Size Analysis Tool
# Usage: ./analyze-size.sh [image-name]

set -e

IMAGE_NAME=${1:-"unityci/multi-platform-editor:ubuntu-2020.1.6f1-android-ios-windows-1.0.0"}

echo "🔍 Analyzing Docker Image Size: $IMAGE_NAME"
echo "=============================================="

# Check if image exists
if ! docker image inspect "$IMAGE_NAME" >/dev/null 2>&1; then
  echo "❌ Image $IMAGE_NAME not found!"
  echo "Available images:"
  docker images | grep multi-platform || echo "No multi-platform images found"
  exit 1
fi

# Get image size
IMAGE_SIZE=$(docker image inspect "$IMAGE_NAME" --format='{{.Size}}')
IMAGE_SIZE_MB=$((IMAGE_SIZE / 1024 / 1024))

echo "📊 Total Image Size: ${IMAGE_SIZE_MB} MB"
echo ""

# Analyze layers
echo "📋 Layer Analysis:"
echo "------------------"
docker history "$IMAGE_NAME" --format "table {{.Size}}\t{{.CreatedBy}}" | head -20

echo ""
echo "🔍 Largest Components Analysis:"
echo "------------------------------"

# Create temporary container to analyze content
CONTAINER_ID=$(docker create "$IMAGE_NAME")

echo "Unity Editor size:"
docker exec $CONTAINER_ID du -sh /opt/unity 2>/dev/null || echo "Unity not found"

echo "Wine size:"
docker exec $CONTAINER_ID du -sh /usr/lib/wine 2>/dev/null || echo "Wine not found"

echo "Java size:"
docker exec $CONTAINER_ID du -sh /usr/lib/jvm 2>/dev/null || echo "Java not found"

echo "Package cache:"
docker exec $CONTAINER_ID du -sh /var/lib/apt 2>/dev/null || echo "No package cache"

echo "Temp files:"
docker exec $CONTAINER_ID du -sh /tmp 2>/dev/null || echo "No temp files"

echo "Log files:"
docker exec $CONTAINER_ID du -sh /var/log 2>/dev/null || echo "No log files"

# Cleanup
docker rm $CONTAINER_ID >/dev/null

echo ""
echo "💡 Optimization Recommendations:"
echo "--------------------------------"

if [ $IMAGE_SIZE_MB -gt 8000 ]; then
  echo "🔴 Very Large (${IMAGE_SIZE_MB}MB) - Consider:"
  echo "   • Use multi-stage builds to exclude build tools"
  echo "   • Remove unnecessary Unity modules"
  echo "   • Use alpine-based images where possible"
elif [ $IMAGE_SIZE_MB -gt 5000 ]; then
  echo "🟡 Large (${IMAGE_SIZE_MB}MB) - Consider:"
  echo "   • Combine RUN instructions"
  echo "   • Clean package caches more aggressively"
  echo "   • Remove Wine if Windows builds not needed"
elif [ $IMAGE_SIZE_MB -gt 3000 ]; then
  echo "🟡 Medium (${IMAGE_SIZE_MB}MB) - Consider:"
  echo "   • Remove documentation and man pages"
  echo "   • Use --no-install-recommends more aggressively"
else
  echo "🟢 Optimized (${IMAGE_SIZE_MB}MB) - Good size!"
fi

echo ""
echo "🛠️  Size Comparison Commands:"
echo "----------------------------"
echo "# Compare with Ubuntu base:"
echo "docker images ubuntu:22.04"
echo ""
echo "# Compare all multi-platform images:"
echo "docker images | grep multi-platform"
echo ""
echo "# Detailed layer analysis:"
echo "docker history $IMAGE_NAME --no-trunc"
