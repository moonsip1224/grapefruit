#!/bin/bash

# Install Roblox Studio via Wine
echo "Installing Roblox Studio..."

# Set Wine prefix
export WINEPREFIX=/home/vncuser/.wine

# Switch to vncuser
su - vncuser << 'EOF'
export WINEPREFIX=/home/vncuser/.wine
export DISPLAY=:1

# Initialize Wine if not already done
if [ ! -d "$WINEPREFIX" ]; then
    echo "Initializing Wine..."
    winecfg
fi

# Download Roblox Studio installer
echo "Downloading Roblox Studio..."
cd /tmp
wget -O RobloxStudio.exe "https://setup.rbxcdn.com/RobloxStudioLauncherBeta.exe"

# Install Roblox Studio
echo "Installing Roblox Studio via Wine..."
wine RobloxStudio.exe /S

# Wait for installation to complete
sleep 30

echo "Roblox Studio installation completed!"
EOF