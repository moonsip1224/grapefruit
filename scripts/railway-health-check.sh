#!/bin/bash

# Simple health check for Railway deployment

# Check if websockify is running (this serves noVNC)
if ! pgrep -f "websockify" > /dev/null; then
    echo "Websockify (noVNC) is not running"
    exit 1
fi

# Check if the noVNC port is listening
if ! nc -z localhost ${PORT:-6080}; then
    echo "noVNC port ${PORT:-6080} is not listening"
    exit 1
fi

# Check if VNC server is running (internal)
if ! pgrep -f "Xvnc" > /dev/null; then
    echo "VNC server is not running"
    exit 1
fi

echo "healthy"
exit 0