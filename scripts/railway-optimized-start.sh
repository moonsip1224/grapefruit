#!/bin/bash

# Railway-optimized startup script for Roblox Studio Web
# This script is specifically designed for Railway's constraints

echo "🚀 Starting Railway Roblox Studio Environment (noVNC only)..."

# Set Railway environment variables
export PORT=${PORT:-6080}
export RESOLUTION=${RESOLUTION:-1920x1080}
export COLOR_DEPTH=${COLOR_DEPTH:-24}
export VNC_PASSWORD=${VNC_PASSWORD:-robloxstudio2024}

echo "📋 Configuration:"
echo "  Port: $PORT"
echo "  Resolution: $RESOLUTION"
echo "  Color Depth: $COLOR_DEPTH"

# Create necessary directories
mkdir -p /var/log /var/run /home/vncuser/.vnc

# Set VNC password for vncuser
echo "$VNC_PASSWORD" | su - vncuser -c "vncpasswd -f > ~/.vnc/passwd && chmod 600 ~/.vnc/passwd"

# Create optimized VNC startup script
su - vncuser -c "cat > ~/.vnc/xstartup << 'EOF'
#!/bin/bash
unset SESSION_MANAGER
unset DBUS_SESSION_BUS_ADDRESS
xrdb \$HOME/.Xresources 2>/dev/null || true
xsetroot -solid grey
export XKL_XMODMAP_DISABLE=1
/usr/bin/startxfce4 &
EOF
chmod +x ~/.vnc/xstartup"

# Start VNC server (internal only - not exposed to Railway)
echo "🖥️  Starting VNC server..."
su - vncuser -c "vncserver :1 -geometry $RESOLUTION -depth $COLOR_DEPTH" &

# Wait for VNC to be ready
sleep 10

# Start websockify with noVNC web interface directly on Railway port
echo "🌐 Starting noVNC web interface on port $PORT..."
websockify --web /usr/share/novnc $PORT localhost:5901 &

# Install Roblox Studio in background if not present
if [ ! -f "/home/vncuser/.wine/drive_c/users/vncuser/AppData/Local/Roblox/Versions/RobloxStudioBeta.exe" ]; then
    echo "🎮 Installing Roblox Studio in background..."
    /opt/install-roblox.sh &
fi

echo "✅ Environment ready!"
echo "🔗 Access via your Railway URL"
echo "🔑 VNC Password: $VNC_PASSWORD"
echo "📱 Resolution: $RESOLUTION"

# Keep the container running and monitor processes
while true; do
    # Check if VNC is still running
    if ! pgrep -f "Xvnc" > /dev/null; then
        echo "❌ VNC server died, restarting..."
        su - vncuser -c "vncserver :1 -geometry $RESOLUTION -depth $COLOR_DEPTH" &
        sleep 5
    fi
    
    # Check if websockify is still running
    if ! pgrep -f "websockify" > /dev/null; then
        echo "❌ Websockify died, restarting..."
        websockify --web /usr/share/novnc $PORT localhost:5901 &
        sleep 5
    fi
    
    sleep 30
done