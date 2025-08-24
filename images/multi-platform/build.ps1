# Multi-Platform Unity Docker Image Build Script for Windows
# Usage: .\build.ps1 [UnityVersion] [UnityChangeset] [TagSuffix]

param(
  [string]$UnityVersion = "2020.1.6f1",
  [string]$UnityChangeset = "fc477ca6df10",
  [string]$TagSuffix = "1.0.0"
)

# Error handling
$ErrorActionPreference = "Stop"

# Build arguments
$BaseImageTag = "unityci/multi-platform-base:$TagSuffix"
$HubImageTag = "unityci/multi-platform-hub:$TagSuffix"
$EditorImageTag = "unityci/multi-platform-editor:ubuntu-$UnityVersion-android-ios-windows-$TagSuffix"

Write-Host "Building Multi-Platform Unity Docker Images..." -ForegroundColor Green
Write-Host "Unity Version: $UnityVersion" -ForegroundColor Yellow
Write-Host "Unity Changeset: $UnityChangeset" -ForegroundColor Yellow
Write-Host "Tag Suffix: $TagSuffix" -ForegroundColor Yellow
Write-Host ""

try {
  # Build base image
  Write-Host "Building base image: $BaseImageTag" -ForegroundColor Cyan
  docker build `
    -t $BaseImageTag `
    --build-arg INSTALL_WINE="true" `
    --build-arg INSTALL_IOS_TOOLS="true" `
    -f images/multi-platform/base/Dockerfile `
    images/multi-platform/base/

  if ($LASTEXITCODE -ne 0) {
    throw "Base image build failed"
  }

  Write-Host "Base image built successfully!" -ForegroundColor Green
  Write-Host ""

  # Build hub image
  Write-Host "Building hub image: $HubImageTag" -ForegroundColor Cyan
  docker build `
    -t $HubImageTag `
    --build-arg baseImage=$BaseImageTag `
    -f images/multi-platform/hub/Dockerfile `
    images/multi-platform/hub/

  if ($LASTEXITCODE -ne 0) {
    throw "Hub image build failed"
  }

  Write-Host "Hub image built successfully!" -ForegroundColor Green
  Write-Host ""

  # Build editor image
  Write-Host "Building editor image: $EditorImageTag" -ForegroundColor Cyan
  docker build `
    -t $EditorImageTag `
    --build-arg hubImage=$HubImageTag `
    --build-arg baseImage=$BaseImageTag `
    --build-arg version=$UnityVersion `
    --build-arg changeSet=$UnityChangeset `
    --build-arg module="android-ios-windows" `
    -f images/multi-platform/editor/Dockerfile `
    images/multi-platform/editor/

  if ($LASTEXITCODE -ne 0) {
    throw "Editor image build failed"
  }

  Write-Host "Editor image built successfully!" -ForegroundColor Green
  Write-Host ""

  Write-Host "All images built successfully!" -ForegroundColor Green
  Write-Host "Available images:" -ForegroundColor Yellow
  Write-Host "  Base: $BaseImageTag" -ForegroundColor White
  Write-Host "  Hub: $HubImageTag" -ForegroundColor White
  Write-Host "  Editor: $EditorImageTag" -ForegroundColor White
  Write-Host ""
  Write-Host "Usage examples:" -ForegroundColor Yellow
  Write-Host "  docker run -it --rm $EditorImageTag bash" -ForegroundColor White
  Write-Host "  docker run -it --rm $EditorImageTag unity-multiplatform-build android /project /build" -ForegroundColor White

}
catch {
  Write-Host "Build failed: $($_.Exception.Message)" -ForegroundColor Red
  exit 1
}
