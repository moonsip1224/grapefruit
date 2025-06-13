#!/bin/bash

# Roblox Studio on Railway - Setup Script

set -e

echo "🎮 Roblox Studio on Railway - Setup Script"
echo "=========================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if we're in the right directory
if [ ! -f "railway.toml" ]; then
    print_error "railway.toml not found. Please run this script from the project root."
    exit 1
fi

print_status "Checking prerequisites..."

# Check if Docker is installed (for local testing)
if command -v docker &> /dev/null; then
    print_success "Docker is installed"
    DOCKER_AVAILABLE=true
else
    print_warning "Docker not found (optional for Railway deployment)"
    DOCKER_AVAILABLE=false
fi

# Check if Railway CLI is installed
if command -v railway &> /dev/null; then
    print_success "Railway CLI is installed"
    RAILWAY_AVAILABLE=true
else
    print_warning "Railway CLI not found"
    RAILWAY_AVAILABLE=false
fi

# Check if git is available
if command -v git &> /dev/null; then
    print_success "Git is available"
    GIT_AVAILABLE=true
else
    print_error "Git is required but not found"
    exit 1
fi

echo ""
print_status "Setup Options:"
echo "1. Deploy to Railway (recommended)"
echo "2. Test locally with Docker"
echo "3. Install Railway CLI"
echo "4. Setup development environment"
echo "5. Exit"

read -p "Choose an option (1-5): " choice

case $choice in
    1)
        print_status "Setting up Railway deployment..."
        
        if [ "$RAILWAY_AVAILABLE" = false ]; then
            print_status "Installing Railway CLI..."
            curl -fsSL https://railway.app/install.sh | sh
            export PATH="$HOME/.railway/bin:$PATH"
        fi
        
        print_status "Checking Railway authentication..."
        if ! railway whoami &> /dev/null; then
            print_status "Please login to Railway:"
            railway login
        fi
        
        print_status "Deploying to Railway..."
        railway up
        
        print_success "Deployment initiated!"
        print_status "Check your Railway dashboard for the public URL"
        ;;
        
    2)
        if [ "$DOCKER_AVAILABLE" = false ]; then
            print_error "Docker is required for local testing"
            exit 1
        fi
        
        print_status "Building Docker image..."
        docker build -t roblox-studio-web .
        
        print_status "Starting container..."
        docker run -d -p 6080:6080 -p 5901:5901 --name roblox-studio-web roblox-studio-web
        
        print_success "Container started!"
        print_status "Access via: http://localhost:6080"
        print_status "VNC Password: robloxstudio2024"
        ;;
        
    3)
        print_status "Installing Railway CLI..."
        curl -fsSL https://railway.app/install.sh | sh
        export PATH="$HOME/.railway/bin:$PATH"
        print_success "Railway CLI installed!"
        ;;
        
    4)
        print_status "Setting up development environment..."
        
        # Create .env file if it doesn't exist
        if [ ! -f ".env" ]; then
            cp .env.example .env
            print_success "Created .env file from template"
        fi
        
        # Make scripts executable
        chmod +x scripts/*.sh
        print_success "Made scripts executable"
        
        # Initialize git if not already done
        if [ ! -d ".git" ]; then
            git init
            git add .
            git commit -m "Initial commit: Roblox Studio on Railway"
            print_success "Initialized git repository"
        fi
        
        print_success "Development environment ready!"
        ;;
        
    5)
        print_status "Exiting..."
        exit 0
        ;;
        
    *)
        print_error "Invalid option"
        exit 1
        ;;
esac

echo ""
print_success "Setup completed!"
echo ""
print_status "Next steps:"
echo "1. Access your Roblox Studio web interface"
echo "2. Login to your Roblox account"
echo "3. Start building amazing games!"
echo ""
print_status "Documentation:"
echo "- README.md - General information"
echo "- DEPLOYMENT.md - Detailed deployment guide"
echo ""
print_status "Support:"
echo "- GitHub Issues: Create issues for bugs/features"
echo "- Railway Discord: discord.gg/railway"
echo ""
print_success "Happy game development! 🎮"