#!/bin/bash

# Health check script for Railway deployment

# Check if VNC server is running (internal only)
if ! pgrep -f "Xvnc" > /dev/null; then
    echo "VNC server is not running"
    exit 1
fi

# Check if websockify is running
if ! pgrep -f "websockify" > /dev/null; then
    echo "Websockify is not running"
    exit 1
fi

# Check if websockify port is listening (internal)
if ! nc -z localhost 6081; then
    echo "Websockify port 6081 is not listening"
    exit 1
fi

# Check if nginx is running
if ! pgrep -f "nginx" > /dev/null; then
    echo "Nginx is not running"
    exit 1
fi

# Check if nginx port is listening (Railway exposed port)
if ! nc -z localhost 6080; then
    echo "Nginx port 6080 is not listening"
    exit 1
fi

echo "All services are healthy"
exit 0