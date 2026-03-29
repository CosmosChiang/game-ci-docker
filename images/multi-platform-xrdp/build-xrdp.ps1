# Multi-Platform Unity Docker Image Build Script with XRDP Support for Windows
# Usage: .\build-xrdp.ps1 [UnityVersion] [UnityChangeset] [TagSuffix]

param(
  [string]$UnityVersion = "2022.3.0f1",
  [string]$UnityChangeset = "52de8fd3ce",
  [string]$TagSuffix = "1.0.0",
  [string]$UnityModules = "android-ios-windows"
)

# Error handling
$ErrorActionPreference = "Stop"

# Get script directory to handle relative paths correctly
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ProjectRoot = Split-Path -Parent $ScriptDir

# Build arguments
$BaseImageTag = "unityci/multi-platform-xrdp-base:$TagSuffix"
$HubImageTag = "unityci/multi-platform-xrdp-hub:$TagSuffix"
$EditorImageTag = "unityci/multi-platform-xrdp-editor:ubuntu-$UnityVersion-$UnityModules-$TagSuffix"

Write-Host "Building Multi-Platform Unity Docker Images with XRDP Support..." -ForegroundColor Green
Write-Host "Unity Version: $UnityVersion" -ForegroundColor Yellow
Write-Host "Unity Changeset: $UnityChangeset" -ForegroundColor Yellow
Write-Host "Tag Suffix: $TagSuffix" -ForegroundColor Yellow
Write-Host "Unity Modules: $UnityModules" -ForegroundColor Yellow
Write-Host ""

try {
  # Build base image with XRDP support
  Write-Host "Building base image with XRDP: $BaseImageTag" -ForegroundColor Cyan
  docker build `
    -t $BaseImageTag `
    --build-arg INSTALL_WINE="true" `
    --build-arg INSTALL_IOS_TOOLS="true" `
    -f "$ScriptDir/base/Dockerfile" `
    "$ScriptDir/base/"

  if ($LASTEXITCODE -ne 0) {
    throw "Base image build failed"
  }

  Write-Host "Base image with XRDP built successfully!" -ForegroundColor Green
  Write-Host ""

  # Build hub image
  Write-Host "Building hub image with GUI support: $HubImageTag" -ForegroundColor Cyan
  docker build `
    -t $HubImageTag `
    --build-arg baseImage=$BaseImageTag `
    -f "$ScriptDir/hub/Dockerfile" `
    "$ScriptDir/hub/"

  if ($LASTEXITCODE -ne 0) {
    throw "Hub image build failed"
  }

  Write-Host "Hub image with GUI support built successfully!" -ForegroundColor Green
  Write-Host ""

  # Build editor image
  Write-Host "Building editor image with XRDP: $EditorImageTag" -ForegroundColor Cyan
  docker build `
    -t $EditorImageTag `
    --build-arg hubImage=$HubImageTag `
    --build-arg baseImage=$BaseImageTag `
    --build-arg version=$UnityVersion `
    --build-arg changeSet=$UnityChangeset `
    --build-arg module=$UnityModules `
    -f "$ScriptDir/editor/Dockerfile" `
    "$ScriptDir/editor/"

  if ($LASTEXITCODE -ne 0) {
    throw "Editor image build failed"
  }

  Write-Host "Editor image with XRDP built successfully!" -ForegroundColor Green
  Write-Host ""

  Write-Host "All images built successfully!" -ForegroundColor Green
  Write-Host "Available images:" -ForegroundColor Yellow
  Write-Host "  Base: $BaseImageTag" -ForegroundColor White
  Write-Host "  Hub: $HubImageTag" -ForegroundColor White
  Write-Host "  Editor: $EditorImageTag" -ForegroundColor White
  Write-Host ""
  Write-Host "Usage examples:" -ForegroundColor Yellow
  Write-Host "  # Start container with XRDP access" -ForegroundColor Gray
  Write-Host "  docker run -d -p 3389:3389 --name unity-desktop $EditorImageTag" -ForegroundColor White
  Write-Host ""
  Write-Host "  # Connect via Remote Desktop" -ForegroundColor Gray
  Write-Host "  # Server: localhost:3389" -ForegroundColor White
  Write-Host "  # Username: unity" -ForegroundColor White
  Write-Host "  # Password: unity123" -ForegroundColor White
  Write-Host ""
  Write-Host "  # Headless CI/CD usage" -ForegroundColor Gray
  Write-Host "  docker run -it --rm $EditorImageTag unity-multiplatform-build android /project /build" -ForegroundColor White
  Write-Host ""
  Write-Host "  # Mount project and build volumes" -ForegroundColor Gray
  Write-Host "  docker run -d -p 3389:3389 -v `"C:\YourProject:/project`" -v `"C:\YourBuild:/build`" --name unity-desktop $EditorImageTag" -ForegroundColor White

}
catch {
  Write-Host "Build failed: $($_.Exception.Message)" -ForegroundColor Red
  exit 1
}
