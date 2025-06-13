#!/bin/bash

# Health check script for Railway deployment

# Check if VNC server is running
if ! pgrep -f "Xvnc" > /dev/null; then
    echo "VNC server is not running"
    exit 1
fi

# Check if websockify is running
if ! pgrep -f "websockify" > /dev/null; then
    echo "Websockify is not running"
    exit 1
fi

# Check if VNC port is listening
if ! nc -z localhost 5901; then
    echo "VNC port 5901 is not listening"
    exit 1
fi

# Check if websockify port is listening
if ! nc -z localhost 6080; then
    echo "Websockify port 6080 is not listening"
    exit 1
fi

echo "All services are healthy"
exit 0