#!/bin/bash

# Production-grade health check for Railway deployment

set -euo pipefail

# Health check with timeout
timeout_check() {
    local cmd="$1"
    local timeout="${2:-5}"
    
    timeout "$timeout" bash -c "$cmd" 2>/dev/null
}

# Check if websockify is running and responsive
if ! pgrep -f "websockify.*${PORT:-6080}" >/dev/null; then
    echo "ERROR: Websockify (noVNC) is not running"
    exit 1
fi

# Check if the noVNC port is listening and responsive
if ! timeout_check "nc -z localhost ${PORT:-6080}"; then
    echo "ERROR: noVNC port ${PORT:-6080} is not responding"
    exit 1
fi

# Check if VNC server is running
if ! pgrep -f "Xvnc.*:1" >/dev/null; then
    echo "ERROR: VNC server is not running"
    exit 1
fi

# Check if VNC port is listening
if ! timeout_check "nc -z localhost 5901"; then
    echo "ERROR: VNC port 5901 is not responding"
    exit 1
fi

# Optional: Check if X11 is responsive
if ! timeout_check "su - vncuser -c 'DISPLAY=:1 xdpyinfo >/dev/null 2>&1'"; then
    echo "WARNING: X11 display may not be fully responsive"
fi

echo "healthy"
exit 0