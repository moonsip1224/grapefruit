# Troubleshooting Guide

## Common Issues and Solutions

### 1. Docker Build Failures

#### Package Not Found Errors
```
E: Unable to locate package [package-name]
```

**Solution**: The package may not be available in Ubuntu 22.04 repositories.
- Check if the package name is correct
- Try alternative packages
- Update the Dockerfile to remove problematic packages

**Common Package Issues**:
- `file-manager-actions` → Remove (not available in Ubuntu 22.04)
- `firefox-esr` → Use `firefox` instead
- Always verify package names for the specific Ubuntu version

#### Wine Configuration Issues
```
Wine configuration failed
```

**Solution**: 
- Ensure `DEBIAN_FRONTEND=noninteractive` is set
- Use `wineboot --init` instead of `winecfg`
- Set `WINEDLLOVERRIDES` environment variable

### 2. Railway Deployment Issues

#### Build Timeout
**Symptoms**: Build process times out on Railway

**Solutions**:
1. Reduce Docker image size:
   ```dockerfile
   # Remove unnecessary packages
   RUN apt-get clean && rm -rf /var/lib/apt/lists/*
   ```

2. Use multi-stage builds:
   ```dockerfile
   FROM ubuntu:22.04 as base
   # ... install dependencies
   
   FROM base as final
   # ... copy only necessary files
   ```

#### Service Won't Start
**Symptoms**: Container starts but service is unreachable

**Solutions**:
1. Check Railway logs:
   ```bash
   railway logs --follow
   ```

2. Verify port configuration in `railway.toml`:
   ```toml
   [services.variables]
   PORT = "6080"
   ```

3. Ensure health check passes:
   ```bash
   # Test health check locally
   ./scripts/health-check.sh
   ```

### 3. VNC Connection Issues

#### "Connection Failed" Error
**Symptoms**: Cannot connect to VNC through web browser

**Solutions**:
1. Verify VNC server is running:
   ```bash
   ps aux | grep vnc
   ```

2. Check VNC password:
   ```bash
   # Default password is: robloxstudio2024
   ```

3. Verify ports are accessible:
   ```bash
   netstat -tlnp | grep 5901  # VNC port
   netstat -tlnp | grep 6080  # noVNC port
   ```

#### Black Screen or No Desktop
**Symptoms**: VNC connects but shows black screen

**Solutions**:
1. Check XFCE4 is starting:
   ```bash
   ps aux | grep xfce
   ```

2. Verify VNC startup script:
   ```bash
   cat ~/.vnc/xstartup
   ```

3. Check X11 display:
   ```bash
   echo $DISPLAY  # Should be :1
   ```

### 4. Roblox Studio Issues

#### Installation Fails
**Symptoms**: Roblox Studio doesn't install via Wine

**Solutions**:
1. Check Wine version compatibility:
   ```bash
   wine --version
   ```

2. Verify Wine prefix:
   ```bash
   ls -la ~/.wine/
   ```

3. Manual installation:
   ```bash
   # Download installer manually
   wget -O RobloxStudio.exe "https://setup.rbxcdn.com/RobloxStudioLauncherBeta.exe"
   wine RobloxStudio.exe
   ```

#### Performance Issues
**Symptoms**: Roblox Studio runs slowly or crashes

**Solutions**:
1. Reduce desktop resolution:
   ```toml
   # In railway.toml
   RESOLUTION = "1366x768"
   COLOR_DEPTH = "16"
   ```

2. Increase Railway plan resources
3. Close unnecessary applications in desktop

#### Login Issues
**Symptoms**: Cannot login to Roblox account

**Solutions**:
1. Use web browser in desktop environment
2. Clear Wine registry:
   ```bash
   rm -rf ~/.wine/user.reg
   wineboot --init
   ```

### 5. Performance Optimization

#### High Latency
**Symptoms**: Slow response to mouse/keyboard input

**Solutions**:
1. Use lower resolution and color depth
2. Ensure stable internet connection
3. Choose Railway region closest to you
4. Use wired internet connection

#### High Resource Usage
**Symptoms**: Container uses too much CPU/memory

**Solutions**:
1. Monitor resource usage:
   ```bash
   railway status
   ```

2. Optimize Docker image:
   ```dockerfile
   # Remove unnecessary services
   # Use lighter desktop environment
   ```

3. Upgrade Railway plan if needed

### 6. Network Issues

#### Cannot Access Railway URL
**Symptoms**: Railway provides URL but it's not accessible

**Solutions**:
1. Check Railway service status
2. Verify deployment completed successfully
3. Check Railway logs for errors
4. Ensure correct port is exposed (6080)

#### WebSocket Connection Fails
**Symptoms**: noVNC shows "Failed to connect to server"

**Solutions**:
1. Check websockify is running:
   ```bash
   ps aux | grep websockify
   ```

2. Verify WebSocket support:
   ```bash
   curl -H "Upgrade: websocket" http://localhost:6080
   ```

### 7. Data Persistence Issues

#### Lost Files After Restart
**Symptoms**: Projects disappear when container restarts

**Solutions**:
1. Use Roblox's cloud sync features
2. Regularly export projects
3. Consider external storage solutions
4. Use Railway's persistent volumes (if available)

### 8. Security Concerns

#### Default VNC Password
**Symptoms**: Using default password `robloxstudio2024`

**Solutions**:
1. Change password in railway.toml:
   ```toml
   VNC_PASSWORD = "your-secure-password"
   ```

2. Use Railway environment variables for sensitive data

### 9. Debugging Steps

#### General Debugging Process
1. **Check Railway Logs**:
   ```bash
   railway logs --follow
   ```

2. **Verify Service Health**:
   ```bash
   curl https://your-app.railway.app/health
   ```

3. **Test Locally**:
   ```bash
   docker build -t test .
   docker run -p 6080:6080 test
   ```

4. **Check Process Status**:
   ```bash
   # Inside container
   supervisorctl status
   ```

#### Log Locations
- VNC logs: `/var/log/vnc.err.log`, `/var/log/vnc.out.log`
- Websockify logs: `/var/log/websockify.err.log`, `/var/log/websockify.out.log`
- Supervisor logs: `/var/log/supervisord.log`

### 10. Getting Help

#### Before Asking for Help
1. Check this troubleshooting guide
2. Review Railway logs
3. Test locally if possible
4. Document exact error messages

#### Where to Get Help
1. **Railway Discord**: [discord.gg/railway](https://discord.gg/railway)
2. **GitHub Issues**: Create detailed issue with logs
3. **Railway Documentation**: [docs.railway.app](https://docs.railway.app)

#### Information to Include
- Railway logs
- Error messages
- Steps to reproduce
- Railway plan type
- Browser and OS information

---

**Remember**: This setup runs Windows applications (Roblox Studio) on Linux via Wine, which may have compatibility limitations. Some features may not work perfectly.