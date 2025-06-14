#!/bin/bash

# Production-grade Roblox Studio installer via Wine
# Includes error handling, retries, and progress tracking

set -euo pipefail

# Logging function
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] ROBLOX-INSTALL: $1" >&2
}

log "Starting Roblox Studio installation..."

# Set Wine environment with proper architecture support
export WINEPREFIX=/home/vncuser/.wine
export DISPLAY=:1
export WINEDLLOVERRIDES="mscoree,mshtml="
export WINEARCH=win64  # Use 64-bit wine prefix but with 32-bit support

# Download function with retry logic
download_with_retry() {
    local url="$1"
    local output="$2"
    local max_retries=3
    local retry_count=0
    
    while [ $retry_count -lt $max_retries ]; do
        log "Downloading Roblox Studio (attempt $((retry_count + 1))/$max_retries)..."
        
        if wget --timeout=30 --tries=3 -O "$output" "$url"; then
            log "Download completed successfully"
            return 0
        else
            retry_count=$((retry_count + 1))
            log "Download failed (attempt $retry_count/$max_retries)"
            [ $retry_count -lt $max_retries ] && sleep 10
        fi
    done
    
    log "Failed to download after $max_retries attempts"
    return 1
}

# Execute as vncuser with proper error handling
su - vncuser << 'EOF'
set -euo pipefail

# Logging function for vncuser context
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] ROBLOX-INSTALL: $1" >&2
}

export WINEPREFIX=/home/vncuser/.wine
export DISPLAY=:1
export WINEDLLOVERRIDES="mscoree,mshtml="
export WINEARCH=win64

# Initialize Wine if not already done
if [ ! -d "$WINEPREFIX" ]; then
    log "Initializing Wine environment with multiarch support..."
    
    # Create wine prefix with explicit architecture
    WINEARCH=win64 wineboot --init
    
    # Wait for wineboot to complete
    local wait_count=0
    while pgrep -f wineboot >/dev/null && [ $wait_count -lt 30 ]; do
        log "Waiting for Wine initialization... ($wait_count/30)"
        sleep 2
        wait_count=$((wait_count + 1))
    done
    
    # Kill any hanging wineboot processes
    pkill -f wineboot 2>/dev/null || true
    
    log "Setting Wine to Windows 10 mode..."
    winetricks -q --force win10 2>/dev/null || {
        log "Warning: Failed to set Windows 10 mode, trying alternative..."
        winecfg /v win10 2>/dev/null || true
    }
    
    log "Installing essential Windows components..."
    # Install components one by one with error handling
    winetricks -q --force corefonts 2>/dev/null || {
        log "Warning: Failed to install corefonts"
    }
    
    winetricks -q --force vcrun2019 2>/dev/null || {
        log "Warning: Failed to install vcrun2019, trying vcrun2017..."
        winetricks -q --force vcrun2017 2>/dev/null || {
            log "Warning: Failed to install Visual C++ runtime"
        }
    }
    
    log "Wine initialization completed"
else
    log "Wine environment already exists"
fi

# Create temp directory
mkdir -p /tmp/roblox-install
cd /tmp/roblox-install

# Download Roblox Studio installer
log "Downloading Roblox Studio installer..."
if ! wget --timeout=60 --tries=3 -O RobloxStudio.exe "https://setup.rbxcdn.com/RobloxStudioLauncherBeta.exe"; then
    log "Failed to download Roblox Studio installer"
    exit 1
fi

# Verify download
if [ ! -f "RobloxStudio.exe" ] || [ ! -s "RobloxStudio.exe" ]; then
    log "Downloaded file is invalid or empty"
    exit 1
fi

log "Downloaded installer size: $(du -h RobloxStudio.exe | cut -f1)"

# Install Roblox Studio
log "Installing Roblox Studio via Wine..."
if wine RobloxStudio.exe /S; then
    log "Roblox Studio installation command completed"
else
    log "Warning: Installation command returned error, but this might be normal"
fi

# Wait for installation to complete and verify
log "Waiting for installation to complete..."
sleep 30

# Check if installation was successful
local_appdata="$WINEPREFIX/drive_c/users/$(whoami)/AppData/Local"
roblox_path="$local_appdata/Roblox"

if [ -d "$roblox_path" ]; then
    log "✅ Roblox Studio installation successful!"
    log "Installation directory: $roblox_path"
    
    # List installed versions
    if [ -d "$roblox_path/Versions" ]; then
        log "Installed versions:"
        ls -la "$roblox_path/Versions/" | head -10
    fi
else
    log "❌ Roblox Studio installation may have failed"
    log "Checking Wine drive_c structure..."
    ls -la "$WINEPREFIX/drive_c/users/$(whoami)/AppData/Local/" 2>/dev/null || true
fi

# Cleanup
rm -f /tmp/roblox-install/RobloxStudio.exe
log "Installation process completed"
EOF

log "Roblox Studio installation script finished"