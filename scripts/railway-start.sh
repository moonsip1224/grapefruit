#!/bin/bash

# Production-grade Railway startup script for Roblox Studio Web
# Handles all services with proper error handling and monitoring

set -euo pipefail

# Logging function
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >&2
}

log "🚀 Starting Railway Roblox Studio Environment..."

# Validate environment variables
validate_env() {
    local port="${PORT:-6080}"
    local resolution="${RESOLUTION:-1920x1080}"
    local color_depth="${COLOR_DEPTH:-24}"
    local vnc_password="${VNC_PASSWORD:-robloxstudio2024}"
    
    # Validate port
    if ! [[ "$port" =~ ^[0-9]+$ ]] || [ "$port" -lt 1024 ] || [ "$port" -gt 65535 ]; then
        log "❌ Invalid PORT: $port"
        exit 1
    fi
    
    # Validate resolution
    if ! [[ "$resolution" =~ ^[0-9]+x[0-9]+$ ]]; then
        log "❌ Invalid RESOLUTION: $resolution"
        exit 1
    fi
    
    # Validate color depth
    if ! [[ "$color_depth" =~ ^(8|16|24|32)$ ]]; then
        log "❌ Invalid COLOR_DEPTH: $color_depth"
        exit 1
    fi
    
    # Validate password length
    if [ ${#vnc_password} -lt 6 ]; then
        log "❌ VNC_PASSWORD must be at least 6 characters"
        exit 1
    fi
    
    export PORT="$port"
    export RESOLUTION="$resolution"
    export COLOR_DEPTH="$color_depth"
    export VNC_PASSWORD="$vnc_password"
    export VNC_GEOMETRY="$resolution"
}

# Check dependencies
check_dependencies() {
    local missing_deps=""
    
    for cmd in vncserver websockify wine; do
        if ! command -v "$cmd" >/dev/null 2>&1; then
            missing_deps="$missing_deps $cmd"
        fi
    done
    
    if [ -n "$missing_deps" ]; then
        log "❌ Missing dependencies:$missing_deps"
        log "🔧 Installing missing dependencies..."
        apt-get update -qq && apt-get install -y $missing_deps
    fi
}

# Setup directories and permissions
setup_environment() {
    log "🔧 Setting up environment..."
    
    # Create necessary directories
    mkdir -p /var/log /var/run /home/vncuser/.vnc /tmp/vnc
    
    # Set proper permissions
    chown -R vncuser:vncuser /home/vncuser
    chmod 755 /home/vncuser/.vnc
    
    # Create VNC password file
    echo "$VNC_PASSWORD" | su - vncuser -c "vncpasswd -f > ~/.vnc/passwd && chmod 600 ~/.vnc/passwd"
    
    # Create X authority file
    su - vncuser -c "touch ~/.Xauthority && chmod 600 ~/.Xauthority"
    
    # Create optimized VNC startup script
    su - vncuser -c "cat > ~/.vnc/xstartup << 'EOF'
#!/bin/bash
# VNC startup script for XFCE4

# Clear environment
unset SESSION_MANAGER
unset DBUS_SESSION_BUS_ADDRESS

# Set display
export DISPLAY=:1

# Load X resources
xrdb \$HOME/.Xresources 2>/dev/null || true

# Set background
xsetroot -solid '#2e3440' 2>/dev/null || true

# Disable keyboard mapping issues
export XKL_XMODMAP_DISABLE=1

# Start D-Bus session
if [ -z \"\$DBUS_SESSION_BUS_ADDRESS\" ]; then
    eval \$(dbus-launch --sh-syntax) 2>/dev/null || true
fi

# Start window manager with fallback
if command -v startxfce4 >/dev/null 2>&1; then
    exec startxfce4 2>/dev/null
else
    # Fallback to basic window manager
    exec xfwm4 2>/dev/null || exec twm 2>/dev/null
fi
EOF
chmod +x ~/.vnc/xstartup"

    # Create VNC config file
    su - vncuser -c "cat > ~/.vnc/config << 'EOF'
session=startxfce4
geometry=$VNC_GEOMETRY
localhost
alwaysshared
dontdisconnect
depth=$COLOR_DEPTH
EOF"
}

# Start VNC server with retry logic
start_vnc() {
    log "🖥️  Starting VNC server..."
    
    local max_retries=5
    local retry_count=0
    
    while [ $retry_count -lt $max_retries ]; do
        # Kill any existing VNC processes thoroughly
        pkill -f "Xvnc.*:1" || true
        pkill -f "vnc.*:1" || true
        su - vncuser -c "vncserver -kill :1" 2>/dev/null || true
        
        # Clean up VNC lock files
        rm -f /tmp/.X1-lock /tmp/.X11-unix/X1 /home/vncuser/.vnc/*.pid 2>/dev/null || true
        
        # Wait for cleanup
        sleep 3
        
        # Check if display is still in use
        if netstat -ln 2>/dev/null | grep -q ":5901" || ss -ln 2>/dev/null | grep -q ":5901"; then
            log "⚠️  Display :1 still in use, waiting..."
            sleep 5
            continue
        fi
        
        # Start VNC server with compatible settings
        log "Starting VNC server (attempt $((retry_count + 1))/$max_retries)..."
        if su - vncuser -c "vncserver :1 -geometry $VNC_GEOMETRY -depth $COLOR_DEPTH -localhost -dontdisconnect"; then
            # Wait and verify VNC is running
            sleep 5
            if pgrep -f "Xvnc.*:1" >/dev/null && (netstat -ln 2>/dev/null | grep -q ":5901" || ss -ln 2>/dev/null | grep -q ":5901"); then
                log "✅ VNC server started successfully"
                return 0
            else
                log "⚠️  VNC server process died immediately"
            fi
        else
            log "⚠️  VNC server command failed"
        fi
        
        retry_count=$((retry_count + 1))
        [ $retry_count -lt $max_retries ] && sleep 5
    done
    
    log "❌ Failed to start VNC server after $max_retries attempts"
    log "Checking VNC logs..."
    su - vncuser -c "cat ~/.vnc/*.log 2>/dev/null | tail -30" || true
    log "Checking xstartup script..."
    su - vncuser -c "cat ~/.vnc/xstartup" || true
    log "Testing XFCE4 availability..."
    command -v startxfce4 && echo "startxfce4 found" || echo "startxfce4 NOT found"
    return 1
}

# Start websockify with retry logic
start_websockify() {
    log "🌐 Starting noVNC web interface on port $PORT..."
    
    # Find noVNC path
    local novnc_path=""
    for path in "/usr/share/novnc" "/usr/share/novnc-core" "/usr/share/webapps/novnc"; do
        if [ -d "$path" ]; then
            novnc_path="$path"
            break
        fi
    done
    
    # Kill any existing websockify processes
    pkill -f "websockify.*$PORT" || true
    sleep 2
    
    # Start websockify
    if [ -n "$novnc_path" ]; then
        websockify --web "$novnc_path" --log-file=/var/log/websockify.log "$PORT" localhost:5901 &
        local websockify_pid=$!
        log "✅ noVNC started with web interface (PID: $websockify_pid)"
    else
        websockify --log-file=/var/log/websockify.log "$PORT" localhost:5901 &
        local websockify_pid=$!
        log "✅ Websockify started without web interface (PID: $websockify_pid)"
    fi
    
    echo $websockify_pid > /var/run/websockify.pid
}

# Install Roblox Studio in background
install_roblox() {
    local roblox_exe="/home/vncuser/.wine/drive_c/users/vncuser/AppData/Local/Roblox/Versions/RobloxStudioBeta.exe"
    
    if [ ! -f "$roblox_exe" ]; then
        log "🎮 Installing Roblox Studio in background..."
        {
            /opt/install-roblox.sh 2>&1 | while IFS= read -r line; do
                log "ROBLOX: $line"
            done
        } &
        echo $! > /var/run/roblox-install.pid
    else
        log "✅ Roblox Studio already installed"
    fi
}

# Health check function
health_check() {
    # Check VNC server
    if ! pgrep -f "Xvnc.*:1" >/dev/null; then
        return 1
    fi
    
    # Check websockify
    if ! pgrep -f "websockify.*$PORT" >/dev/null; then
        return 1
    fi
    
    # Check ports
    if ! nc -z localhost 5901 || ! nc -z localhost "$PORT"; then
        return 1
    fi
    
    return 0
}

# Process monitoring and restart logic
monitor_processes() {
    log "👀 Starting process monitoring..."
    local vnc_restart_count=0
    local ws_restart_count=0
    local max_restarts=5
    
    while true; do
        # Check VNC server
        if ! pgrep -f "Xvnc.*:1" >/dev/null || ! (netstat -ln 2>/dev/null | grep -q ":5901" || ss -ln 2>/dev/null | grep -q ":5901"); then
            if [ $vnc_restart_count -lt $max_restarts ]; then
                vnc_restart_count=$((vnc_restart_count + 1))
                log "❌ VNC server died, restarting (attempt $vnc_restart_count/$max_restarts)..."
                if start_vnc; then
                    vnc_restart_count=0  # Reset counter on successful restart
                else
                    log "❌ Failed to restart VNC server"
                    if [ $vnc_restart_count -ge $max_restarts ]; then
                        log "❌ Too many VNC restart failures, exiting"
                        exit 1
                    fi
                fi
            else
                log "❌ VNC server restart limit exceeded"
                exit 1
            fi
        fi
        
        # Check websockify
        if ! pgrep -f "websockify.*$PORT" >/dev/null || ! (netstat -ln 2>/dev/null | grep -q ":$PORT" || ss -ln 2>/dev/null | grep -q ":$PORT"); then
            if [ $ws_restart_count -lt $max_restarts ]; then
                ws_restart_count=$((ws_restart_count + 1))
                log "❌ Websockify died, restarting (attempt $ws_restart_count/$max_restarts)..."
                start_websockify
                # Verify websockify started
                sleep 3
                if pgrep -f "websockify.*$PORT" >/dev/null; then
                    ws_restart_count=0  # Reset counter on successful restart
                fi
            else
                log "❌ Websockify restart limit exceeded"
                exit 1
            fi
        fi
        
        # Log status every 5 minutes
        if [ $(($(date +%s) % 300)) -eq 0 ]; then
            log "✅ Services status - VNC: $(pgrep -f "Xvnc.*:1" | wc -l), WebSockify: $(pgrep -f "websockify.*$PORT" | wc -l)"
            log "📊 Port status - VNC:5901: $(netstat -ln 2>/dev/null | grep -c ":5901"), Web:$PORT: $(netstat -ln 2>/dev/null | grep -c ":$PORT")"
        fi
        
        sleep 30
    done
}

# Graceful shutdown handler
cleanup() {
    log "🛑 Shutting down services..."
    
    # Stop Roblox installation if running
    if [ -f /var/run/roblox-install.pid ]; then
        kill "$(cat /var/run/roblox-install.pid)" 2>/dev/null || true
        rm -f /var/run/roblox-install.pid
    fi
    
    # Stop websockify
    if [ -f /var/run/websockify.pid ]; then
        kill "$(cat /var/run/websockify.pid)" 2>/dev/null || true
        rm -f /var/run/websockify.pid
    fi
    pkill -f "websockify.*$PORT" || true
    
    # Stop VNC server
    su - vncuser -c "vncserver -kill :1" 2>/dev/null || true
    pkill -f "Xvnc.*:1" || true
    
    log "✅ Cleanup completed"
    exit 0
}

# Set up signal handlers
trap cleanup SIGTERM SIGINT SIGQUIT

# Main execution
main() {
    validate_env
    check_dependencies
    setup_environment
    
    # Start services
    start_vnc || exit 1
    sleep 5  # Give VNC time to fully start
    start_websockify
    
    # Wait for services to be ready
    local wait_count=0
    while ! health_check && [ $wait_count -lt 30 ]; do
        log "⏳ Waiting for services to be ready..."
        sleep 2
        wait_count=$((wait_count + 1))
    done
    
    if ! health_check; then
        log "❌ Services failed to start properly"
        exit 1
    fi
    
    install_roblox
    
    log "✅ All services started successfully!"
    log "🔗 Access via your Railway URL"
    log "🔑 VNC Password: [REDACTED]"
    log "📱 Resolution: $RESOLUTION"
    
    # Start monitoring
    monitor_processes
}

# Execute main function
main "$@"
