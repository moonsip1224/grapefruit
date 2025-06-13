#!/bin/bash

# Railway Deployment Script for Roblox Studio Web

set -e

echo "🚀 Deploying Roblox Studio Web to Railway..."

# Check if Railway CLI is installed
if ! command -v railway &> /dev/null; then
    echo "❌ Railway CLI not found. Installing..."
    curl -fsSL https://railway.app/install.sh | sh
    export PATH="$HOME/.railway/bin:$PATH"
fi

# Login to Railway (if not already logged in)
echo "🔐 Checking Railway authentication..."
if ! railway whoami &> /dev/null; then
    echo "Please login to Railway:"
    railway login
fi

# Initialize Railway project if not exists
if [ ! -f "railway.toml" ]; then
    echo "❌ railway.toml not found!"
    exit 1
fi

# Deploy to Railway
echo "📦 Deploying to Railway..."
railway up

echo "✅ Deployment initiated!"
echo ""
echo "📋 Next steps:"
echo "1. Go to your Railway dashboard: https://railway.app/dashboard"
echo "2. Find your roblox-studio-web service"
echo "3. Click on it to get the public URL"
echo "4. Access Roblox Studio through your browser!"
echo ""
echo "🔑 VNC Password: robloxstudio2024"
echo "📱 Resolution: 1920x1080"
echo ""
echo "🎮 Happy game development!"