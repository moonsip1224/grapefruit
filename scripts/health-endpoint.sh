#!/bin/bash

# Health endpoint for Railway deployment
# This script provides a simple HTTP health check endpoint

set -euo pipefail

# Default port for health endpoint
HEALTH_PORT="${HEALTH_PORT:-8080}"

# Health check logic
health_check() {
    # Check if websockify is running and responsive
    if ! pgrep -f "websockify.*${PORT:-6080}" >/dev/null; then
        echo "ERROR: Websockify not running"
        return 1
    fi
    
    # Check if VNC server is running
    if ! pgrep -f "Xvnc.*:1" >/dev/null; then
        echo "ERROR: VNC server not running"
        return 1
    fi
    
    # Check if ports are responsive
    if ! nc -z localhost "${PORT:-6080}" || ! nc -z localhost 5901; then
        echo "ERROR: Ports not responding"
        return 1
    fi
    
    echo "OK"
    return 0
}

# Simple HTTP server using netcat
start_health_server() {
    while true; do
        {
            if health_check >/dev/null 2>&1; then
                echo -e "HTTP/1.1 200 OK\r\nContent-Type: text/plain\r\nContent-Length: 7\r\n\r\nhealthy"
            else
                echo -e "HTTP/1.1 503 Service Unavailable\r\nContent-Type: text/plain\r\nContent-Length: 9\r\n\r\nunhealthy"
            fi
        } | nc -l -p "$HEALTH_PORT" -q 1
    done
}

# Start the health server in background if requested
if [ "${1:-}" = "server" ]; then
    start_health_server &
    exit 0
fi

# Default: just run health check once
health_check
