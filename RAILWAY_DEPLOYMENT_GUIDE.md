# 🚀 Railway Deployment Guide for Roblox Studio

## Quick Start

### 1. Deploy to Railway
1. Go to [Railway.app](https://railway.app)
2. Connect your GitHub account
3. Select this repository (`moonsip1224/grapefruit`)
4. Railway will automatically detect the `railway.toml` configuration
5. Click "Deploy"

### 2. Access Your Roblox Studio
1. Once deployed, Railway will provide a public URL (e.g., `https://your-app.railway.app`)
2. Open the URL in your web browser
3. You'll see the noVNC web interface
4. Enter password: `robloxstudio2024`
5. Wait for the desktop to load
6. Roblox Studio will install automatically on first run

## 🔧 Configuration

### Environment Variables (Already Set)
- `PORT=6080` - Web interface port
- `RESOLUTION=1920x1080` - Desktop resolution
- `VNC_PASSWORD=robloxstudio2024` - VNC access password

### Railway-Specific Features
- ✅ **noVNC Web Interface** - Access through browser only
- ✅ **Automatic Health Checks** - Railway monitors service health
- ✅ **HTTPS by Default** - Secure connection provided by Railway
- ✅ **Auto-restart** - Service restarts automatically if it crashes

## 🎮 Using Roblox Studio

### First Time Setup
1. Wait for the desktop environment to load (may take 1-2 minutes)
2. Roblox Studio will install automatically in the background
3. Once installed, you can find it in the Applications menu
4. Launch Roblox Studio and start building!

### Performance Tips
- Use a stable internet connection for best experience
- The desktop resolution is optimized for 1920x1080
- Files are automatically persisted by Railway's volume management
- Important projects are saved across container restarts

## 🔍 Troubleshooting

### Common Issues

**"Connection Failed" or Black Screen**
- Wait 2-3 minutes for services to fully start
- Refresh the browser page
- Check Railway logs for any errors

**Slow Performance**
- This is normal for containerized desktop environments
- Close unnecessary applications in the desktop
- Use Railway's higher-tier plans for better performance

**Roblox Studio Not Installing**
- Check the desktop for installation progress
- Installation happens automatically on first run
- May take 5-10 minutes depending on connection speed

### Railway Logs
Access logs in Railway dashboard:
1. Go to your Railway project
2. Click on the service
3. View "Logs" tab for debugging information

## 🛡️ Security Notes

- VNC server runs internally only (not exposed to internet)
- Access is only through noVNC web interface
- Railway provides HTTPS encryption by default
- Change the VNC password for production use

## 💰 Cost Considerations

- Railway offers a free tier with usage limits
- Roblox Studio is resource-intensive
- Consider upgrading to a paid plan for extended use
- Monitor your usage in the Railway dashboard

## 🔄 Updates

To update the deployment:
1. Push changes to your GitHub repository
2. Railway will automatically redeploy
3. Or manually trigger a redeploy in Railway dashboard

---

**Ready to build games in the cloud! 🎮**