#!/bin/bash

# Health check script for Railway deployment

# Check if VNC server is running
if ! pgrep -f "Xvnc" > /dev/null; then
    echo "VNC server is not running"
    exit 1
fi

# Check if noVNC is running
if ! pgrep -f "websockify" > /dev/null; then
    echo "noVNC websockify is not running"
    exit 1
fi

# Check if VNC port is listening
if ! nc -z localhost 5901; then
    echo "VNC port 5901 is not listening"
    exit 1
fi

# Check if noVNC port is listening
if ! nc -z localhost 6080; then
    echo "noVNC port 6080 is not listening"
    exit 1
fi

# Check if nginx is running
if ! pgrep -f "nginx" > /dev/null; then
    echo "Nginx is not running"
    exit 1
fi

# Check if nginx port is listening
if ! nc -z localhost 80; then
    echo "Nginx port 80 is not listening"
    exit 1
fi

echo "All services are healthy"
exit 0