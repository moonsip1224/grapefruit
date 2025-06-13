# Roblox Studio on Railway

This project sets up Roblox Studio to run in a web browser through Railway.com using VNC and noVNC.

## Features

- 🎮 Full Roblox Studio access through web browser
- 🖥️ XFCE desktop environment
- 🌐 noVNC web interface
- 🍷 Wine compatibility layer for Windows applications
- ☁️ Deployed on Railway.com

## How it Works

1. **Docker Container**: Ubuntu-based container with XFCE desktop environment
2. **VNC Server**: Internal desktop server (not exposed externally)
3. **noVNC + Websockify**: Web-based VNC client accessible through browser
4. **Wine**: Compatibility layer to run Roblox Studio (Windows app) on Linux
5. **Railway**: Cloud platform hosting the container (VNC-compatible via noVNC only)

## Deployment Instructions

### Option 1: Deploy to Railway (Recommended)

1. **Fork this repository** to your GitHub account

2. **Connect to Railway**:
   - Go to [Railway.app](https://railway.app)
   - Sign up/Login with GitHub
   - Click "New Project"
   - Select "Deploy from GitHub repo"
   - Choose this repository

3. **Configure Environment**:
   - Railway will automatically detect the `railway.toml` configuration
   - The service will be available on port 6080

4. **Access Your Roblox Studio**:
   - Once deployed, Railway will provide a URL
   - Open the URL in your browser
   - You'll see the noVNC interface
   - Password: `robloxstudio2024`

### Option 2: Local Development

```bash
# Build the Docker image
docker build -t roblox-studio-web .

# Run the container
docker run -p 6080:6080 -p 5901:5901 roblox-studio-web

# Access via browser
open http://localhost:6080
```

## Usage

1. **Access the Desktop**: Open the Railway URL in your browser
2. **VNC Password**: Enter `robloxstudio2024` when prompted
3. **Wait for Installation**: Roblox Studio will install automatically on first run
4. **Start Creating**: Once installed, you can launch Roblox Studio and start building games!

## Important Notes

### Performance Considerations
- **Latency**: There will be some input lag due to VNC over the internet
- **Graphics**: Limited to software rendering (no GPU acceleration)
- **Bandwidth**: Video streaming requires good internet connection

### Limitations
- **Publishing**: You'll need to log into your Roblox account to publish games
- **File Access**: Files are stored in the container (consider using cloud storage for persistence)
- **Performance**: Not as smooth as native Roblox Studio

### Recommended Workflow
1. Use this for quick edits and testing
2. For serious development, consider downloading projects locally
3. Use Roblox's built-in cloud sync features when possible

## Troubleshooting

### Connection Issues
- Ensure the Railway service is running
- Check that port 6080 is accessible
- Try refreshing the browser

### Roblox Studio Issues
- If installation fails, restart the container
- Wine compatibility may cause some features to not work perfectly
- For best results, use simple Roblox Studio features

### Performance Issues
- Close unnecessary applications in the desktop environment
- Use a stable internet connection
- Consider using during off-peak hours

## File Structure

```
.
├── Dockerfile              # Container configuration
├── railway.toml            # Railway deployment config
├── supervisord.conf        # Process management
├── scripts/
│   ├── install-roblox.sh  # Roblox Studio installer
│   └── start.sh           # Container startup script
└── README.md              # This file
```

## Security Notes

- The VNC password is set to `robloxstudio2024` (change in production)
- VNC server is only accessible internally via noVNC web interface
- Railway provides HTTPS by default for secure web access
- This setup is intended for development/testing purposes
- Consider additional security measures for production use

## Contributing

Feel free to submit issues and pull requests to improve this setup!

## License

This project is open source. Roblox Studio is property of Roblox Corporation.