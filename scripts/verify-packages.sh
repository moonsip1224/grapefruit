#!/bin/bash

# Package verification script for Ubuntu 22.04
# This script checks if all packages in the Dockerfile are available

echo "🔍 Verifying package availability for Ubuntu 22.04..."

# List of packages from Dockerfile
PACKAGES=(
    "xfce4"
    "xfce4-goodies"
    "tightvncserver"
    "novnc"
    "websockify"
    "wine"
    "winetricks"
    "cabextract"
    "winbind"
    "wget"
    "curl"
    "unzip"
    "supervisor"
    "nginx"
    "x11-utils"
    "x11-apps"
    "pulseaudio"
    "fonts-liberation"
    "fonts-dejavu-core"
    "psmisc"
    "netcat-openbsd"
    "thunar"
    "firefox"
    "gedit"
)

# Function to check if package exists
check_package() {
    local package=$1
    echo -n "Checking $package... "
    
    if docker run --rm ubuntu:22.04 bash -c "apt update -qq && apt-cache show $package >/dev/null 2>&1"; then
        echo "✅ Available"
        return 0
    else
        echo "❌ Not found"
        return 1
    fi
}

# Check if Docker is available
if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not available. Cannot verify packages."
    echo "💡 This script requires Docker to test package availability."
    exit 1
fi

# Check each package
failed_packages=()
for package in "${PACKAGES[@]}"; do
    if ! check_package "$package"; then
        failed_packages+=("$package")
    fi
done

# Summary
echo ""
echo "📊 Package Verification Summary:"
echo "Total packages: ${#PACKAGES[@]}"
echo "Failed packages: ${#failed_packages[@]}"

if [ ${#failed_packages[@]} -eq 0 ]; then
    echo "🎉 All packages are available in Ubuntu 22.04!"
    exit 0
else
    echo "❌ The following packages are not available:"
    for package in "${failed_packages[@]}"; do
        echo "  - $package"
    done
    echo ""
    echo "💡 Consider removing or replacing these packages in the Dockerfile."
    exit 1
fi