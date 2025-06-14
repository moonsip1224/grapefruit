# Roblox Studio on Railway 🎮

Production-grade Roblox Studio deployment running in a web browser via Railway.com using VNC and noVNC.

## 🚀 Quick Deploy

### Deploy to Railway
1. **Fork this repository** to your GitHub account
2. **Deploy to Railway**:
   - Go to [Railway.app](https://railway.app)
   - Click "New Project" → "Deploy from GitHub repo"
   - Select your forked repository
   - Railway will automatically detect the configuration and deploy

3. **Access Roblox Studio**:
   - Railway will provide a public URL
   - Open the URL in your browser
   - Enter VNC password: `robloxstudio2024`
   - Wait for Roblox Studio to install automatically

## 🏗️ Architecture

```
Internet → Railway HTTPS → noVNC Web Interface → VNC Server → XFCE Desktop → Roblox Studio
```

**Components:**
- **Docker Container**: Ubuntu 22.04 with XFCE4 desktop
- **VNC Server**: TightVNC for desktop access (internal only)
- **noVNC**: Web-based VNC client accessible via browser
- **Wine**: Compatibility layer to run Roblox Studio on Linux
- **Railway**: Cloud platform with automatic HTTPS and scaling

## ⚙️ Configuration

### Environment Variables (Pre-configured)
```
PORT=6080                    # Web interface port
DISPLAY=:1                   # X11 display
VNC_PASSWORD=robloxstudio2024 # VNC access password
RESOLUTION=1920x1080         # Desktop resolution
COLOR_DEPTH=24               # Color depth (8/16/24/32)
```

### Security Features
- ✅ VNC server runs internally only (not exposed to internet)
- ✅ Access only through encrypted noVNC web interface
- ✅ Railway provides HTTPS by default
- ✅ Input validation and error handling
- ✅ Process monitoring and auto-restart

## 🎯 Production Features

### Reliability
- **Health Checks**: Automatic service monitoring
- **Auto-restart**: Services restart if they crash
- **Error Handling**: Comprehensive error handling and logging
- **Retry Logic**: Automatic retries for network operations
- **Process Monitoring**: Continuous monitoring of VNC and websockify

### Performance
- **Optimized Startup**: Fast boot with dependency checking
- **Resource Management**: Efficient process management
- **Logging**: Structured logging for debugging
- **Cleanup**: Automatic cleanup of temporary files

## 📁 File Structure

```
├── Dockerfile                    # Container configuration
├── railway.toml                  # Railway deployment config
├── README.md                     # This file
├── .env.example                  # Environment variables template
├── .gitignore                    # Git ignore rules
└── scripts/
    ├── railway-start.sh          # Main startup script
    ├── railway-health-check.sh   # Health check script
    ├── install-roblox.sh         # Roblox Studio installer
    └── health-endpoint.sh        # HTTP health endpoint
```

## 🎮 Using Roblox Studio

### First Launch
1. **Wait for Setup**: Initial startup takes 2-3 minutes
2. **Roblox Installation**: Roblox Studio installs automatically in background
3. **Desktop Access**: Full XFCE4 desktop environment
4. **Launch Studio**: Find Roblox Studio in Applications menu

### Development Workflow
1. **Login**: Use your Roblox account to login
2. **Create**: Build games using full Roblox Studio features
3. **Save**: Projects are automatically saved in the container
4. **Publish**: Publish directly to Roblox from the web interface

## 🔧 Troubleshooting

### Common Issues

**Connection Failed**
- Wait 2-3 minutes for services to start
- Refresh the browser page
- Check Railway deployment logs

**Slow Performance**
- Close unnecessary desktop applications
- Use stable internet connection
- Consider upgrading Railway plan

**Roblox Studio Missing**
- Installation happens automatically on first run
- Check desktop for installation progress
- May take 5-10 minutes depending on connection

### Monitoring
- **Railway Logs**: Check deployment logs in Railway dashboard
- **Health Check**: Service includes built-in health monitoring
- **Process Status**: Automatic restart if services fail

## 💰 Railway Pricing

| Plan | RAM | vCPU | Use Case |
|------|-----|------|----------|
| Hobby | Free tier | Limited | Testing |
| Pro | 8GB+ | Multiple | Development |
| Team | 32GB+ | High | Production |

## 🔒 Security Notes

### Production Recommendations
1. **Change VNC Password**: Update `VNC_PASSWORD` in Railway environment
2. **Monitor Usage**: Keep track of resource usage
3. **Regular Updates**: Keep the deployment updated
4. **Backup Projects**: Use Roblox's cloud sync features

### Default Security
- VNC server is internal only (not exposed to internet)
- HTTPS encryption provided by Railway
- Rate limiting and basic security headers
- Input validation and sanitization

## 🚀 Advanced Usage

### Custom Configuration
Update environment variables in Railway dashboard:
```bash
VNC_PASSWORD=your-secure-password
RESOLUTION=1366x768  # Lower resolution for better performance
COLOR_DEPTH=16       # Reduce color depth for speed
```

### Local Development
```bash
# Build and run locally
docker build -t roblox-studio .
docker run -p 6080:6080 roblox-studio
# Access via http://localhost:6080
```

## 📈 Performance Tips

1. **Optimize Resolution**: Lower resolution = better performance
2. **Stable Internet**: Use wired connection when possible
3. **Close Apps**: Close unnecessary desktop applications
4. **Monitor Resources**: Watch Railway resource usage
5. **Regular Restart**: Restart service periodically for optimal performance

## 🆘 Support

- **GitHub Issues**: Report bugs and request features
- **Railway Discord**: [discord.gg/railway](https://discord.gg/railway)
- **Railway Docs**: [docs.railway.app](https://docs.railway.app)

## 📝 License

This project is open source. Roblox Studio is property of Roblox Corporation.

---

**Ready to build games in the cloud! 🎯**

> **Note**: This setup runs Windows applications on Linux via Wine. Some advanced features may have compatibility limitations.
