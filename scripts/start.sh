#!/bin/bash

echo "Starting Railway Roblox Studio Environment..."

# Set environment variables from Railway
export RESOLUTION=${RESOLUTION:-1920x1080}
export COLOR_DEPTH=${COLOR_DEPTH:-24}
export VNC_PASSWORD=${VNC_PASSWORD:-robloxstudio2024}
export PORT=${PORT:-6080}
export NOVNC_PORT=${NOVNC_PORT:-6080}

# Create necessary directories
mkdir -p /var/log/nginx
mkdir -p /var/run
mkdir -p /home/vncuser/.vnc

# Set VNC password
echo "$VNC_PASSWORD" | su - vncuser -c "vncpasswd -f > ~/.vnc/passwd && chmod 600 ~/.vnc/passwd"

# Create VNC startup script with environment variables
su - vncuser -c "cat > ~/.vnc/xstartup << 'EOF'
#!/bin/bash
xrdb \$HOME/.Xresources 2>/dev/null || true
xsetroot -solid grey
export XKL_XMODMAP_DISABLE=1
/usr/bin/startxfce4 &
EOF
chmod +x ~/.vnc/xstartup"

# Start nginx (will be managed by supervisor)
echo "Nginx will be started by supervisor..."

# Install Roblox Studio if not already installed
if [ ! -f "/home/vncuser/.wine/drive_c/users/vncuser/AppData/Local/Roblox/Versions/RobloxStudioBeta.exe" ]; then
    echo "Installing Roblox Studio in background..."
    /opt/install-roblox.sh &
fi

# Keep the container running and start supervisor
echo "Environment ready!"
echo "VNC Password: $VNC_PASSWORD"
echo "Resolution: $RESOLUTION"
echo "Access via Railway URL"

# Start supervisor to manage VNC and noVNC processes
exec /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf