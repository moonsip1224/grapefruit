# Railway Deployment Guide for Roblox Studio Web

## Quick Deploy to Railway

### Method 1: One-Click Deploy (Recommended)

1. **Fork this repository** to your GitHub account

2. **Deploy to Railway**:
   - Go to [Railway.app](https://railway.app)
   - Click "New Project"
   - Select "Deploy from GitHub repo"
   - Choose your forked repository
   - Railway will automatically detect the `railway.toml` configuration

3. **Access your deployment**:
   - Railway will provide a public URL
   - Open the URL in your browser
   - Enter VNC password: `robloxstudio2024`

### Method 2: Railway CLI

```bash
# Install Railway CLI
curl -fsSL https://railway.app/install.sh | sh

# Login to Railway
railway login

# Deploy from this directory
railway up
```

## Configuration

### Environment Variables

The following environment variables are automatically configured via `railway.toml`:

- `PORT=6080` - Web interface port
- `VNC_PORT=5901` - VNC server port
- `DISPLAY=:1` - X11 display
- `VNC_PASSWORD=robloxstudio2024` - VNC access password
- `RESOLUTION=1920x1080` - Desktop resolution
- `COLOR_DEPTH=24` - Color depth

### Custom Configuration

To customize the deployment, modify `railway.toml`:

```toml
[services.roblox-studio-web.variables]
VNC_PASSWORD = "your-secure-password"
RESOLUTION = "1600x900"
COLOR_DEPTH = "16"
```

## Infrastructure Components

### 1. Docker Container
- **Base**: Ubuntu 22.04
- **Desktop**: XFCE4 (lightweight)
- **VNC Server**: TightVNC
- **Web Interface**: noVNC
- **Reverse Proxy**: Nginx

### 2. Process Management
- **Supervisor**: Manages VNC, noVNC, and Nginx processes
- **Health Checks**: Monitors service availability
- **Auto-restart**: Automatic recovery from failures

### 3. Networking
```
Internet → Railway → noVNC/Websockify (Port 6080) → VNC (Port 5901 - Internal) → Desktop
```

**Note**: Railway doesn't allow direct VNC connections. Only web-based noVNC access is supported.

### 4. Storage
- **Wine Data**: `/home/vncuser/.wine` (Roblox Studio installation)
- **Desktop Files**: `/home/vncuser/Desktop` (Your projects)
- **Logs**: `/var/log` (Service logs)

## Performance Optimization

### Railway Plan Recommendations

| Plan | RAM | CPU | Use Case |
|------|-----|-----|----------|
| Hobby | 512MB | 0.5 vCPU | Light testing |
| Pro | 8GB | 8 vCPU | Development work |
| Team | 32GB | 32 vCPU | Heavy development |

### Optimization Tips

1. **Resolution**: Lower resolution = better performance
   ```toml
   RESOLUTION = "1366x768"  # Instead of 1920x1080
   ```

2. **Color Depth**: Reduce for better performance
   ```toml
   COLOR_DEPTH = "16"  # Instead of 24
   ```

3. **Network**: Use stable internet connection for best experience

## Troubleshooting

### Common Issues

#### 1. Container Won't Start
```bash
# Check Railway logs
railway logs

# Common causes:
# - Insufficient memory
# - Port conflicts
# - Environment variable issues
```

#### 2. VNC Connection Failed
- Verify VNC password: `robloxstudio2024`
- Check if VNC server is running in logs
- Ensure port 5901 is accessible

#### 3. Roblox Studio Installation Failed
- Wine compatibility issues
- Insufficient disk space
- Network connectivity problems

#### 4. Performance Issues
- Reduce resolution and color depth
- Upgrade Railway plan
- Check network latency

### Health Check Endpoints

- **Health Check**: `https://your-app.railway.app/health`
- **Service Status**: Check Railway dashboard

### Log Access

```bash
# View live logs
railway logs --follow

# View specific service logs
railway logs --service roblox-studio-web
```

## Security Considerations

### Production Deployment

1. **Change VNC Password**:
   ```toml
   VNC_PASSWORD = "your-secure-password-here"
   ```

2. **Network Security**:
   - Railway provides HTTPS by default
   - Consider IP whitelisting for sensitive use

3. **Data Persistence**:
   - Projects are stored in container (temporary)
   - Use Roblox's cloud sync features
   - Consider external storage for important files

## Monitoring

### Built-in Monitoring
- **Health Checks**: Automatic service monitoring
- **Railway Metrics**: CPU, memory, network usage
- **Logs**: Centralized logging via Railway

### Custom Monitoring
```bash
# Check service status
curl https://your-app.railway.app/health

# Monitor resource usage
railway status
```

## Scaling

### Horizontal Scaling
- Railway supports multiple instances
- Load balancing for high availability
- Session persistence considerations

### Vertical Scaling
- Upgrade Railway plan for more resources
- Adjust container resources in railway.toml

## Backup and Recovery

### Data Backup
```bash
# Export Wine configuration
docker cp container:/home/vncuser/.wine ./wine-backup

# Export desktop files
docker cp container:/home/vncuser/Desktop ./desktop-backup
```

### Disaster Recovery
1. Redeploy from Git repository
2. Restore Wine configuration
3. Reinstall Roblox Studio if needed

## Cost Optimization

### Railway Pricing
- **Hobby**: $5/month (512MB RAM)
- **Pro**: $20/month (8GB RAM)
- **Team**: Custom pricing

### Cost Reduction Tips
1. Use sleep/wake functionality
2. Scale down during off-hours
3. Monitor resource usage
4. Use appropriate plan for usage

## Support

### Getting Help
1. **Railway Discord**: [discord.gg/railway](https://discord.gg/railway)
2. **Railway Docs**: [docs.railway.app](https://docs.railway.app)
3. **GitHub Issues**: Create issues in this repository

### Contributing
1. Fork the repository
2. Make improvements
3. Submit pull requests
4. Share your experience

---

**Happy Game Development! 🎮**