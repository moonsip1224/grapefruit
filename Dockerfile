# Use Ubuntu as base image with GUI support
FROM ubuntu:22.04

# Avoid prompts from apt
ENV DEBIAN_FRONTEND=noninteractive

# Set display port to avoid crash
ENV DISPLAY=:1

# Set environment variables for Railway
ENV PORT=6080
ENV NOVNC_PORT=6080
ENV RESOLUTION=1920x1080
ENV COLOR_DEPTH=24

# Install system dependencies
RUN apt-get update && apt-get install -y \
    # Desktop environment
    xfce4 xfce4-goodies \
    # VNC server
    tightvncserver \
    # noVNC for web access
    novnc websockify \
    # Wine for running Windows applications
    wine winetricks cabextract \
    # Wine dependencies
    winbind \
    # Additional utilities
    wget curl unzip supervisor nginx \
    # X11 utilities
    x11-utils x11-apps \
    # Audio support
    pulseaudio \
    # Fonts
    fonts-liberation fonts-dejavu-core \
    # Process management
    psmisc \
    # Health check utilities
    netcat-openbsd \
    # File management
    thunar \
    # Additional desktop utilities
    firefox \
    gedit \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Create a user for VNC
RUN useradd -m -s /bin/bash vncuser && \
    echo 'vncuser:vncpassword' | chpasswd

# Switch to vncuser
USER vncuser
WORKDIR /home/vncuser

# Configure Wine (non-interactive)
ENV WINEDLLOVERRIDES="mscoree,mshtml="
RUN wineboot --init

# Set up VNC server
RUN mkdir -p ~/.vnc && \
    echo 'robloxstudio2024' | vncpasswd -f > ~/.vnc/passwd && \
    chmod 600 ~/.vnc/passwd

# Create VNC startup script
RUN echo '#!/bin/bash\n\
xrdb $HOME/.Xresources\n\
xsetroot -solid grey\n\
export XKL_XMODMAP_DISABLE=1\n\
/usr/bin/startxfce4 &\n\
' > ~/.vnc/xstartup && \
    chmod +x ~/.vnc/xstartup

# Switch back to root for final setup
USER root

# Create directories for Roblox Studio
RUN mkdir -p /opt/roblox-studio

# Download Roblox Studio installer (this will be done at runtime)
COPY scripts/install-roblox.sh /opt/install-roblox.sh
RUN chmod +x /opt/install-roblox.sh

# Create nginx configuration for reverse proxy
COPY nginx.conf /etc/nginx/nginx.conf

# Create supervisor configuration
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Create health check scripts
COPY scripts/health-check.sh /health-check.sh
COPY scripts/railway-health-check.sh /railway-health-check.sh
RUN chmod +x /health-check.sh /railway-health-check.sh

# Create startup scripts
COPY scripts/start.sh /start.sh
COPY scripts/railway-optimized-start.sh /scripts/railway-optimized-start.sh
RUN chmod +x /start.sh /scripts/railway-optimized-start.sh

# Note: Railway manages persistent storage - no VOLUME declarations needed

# Expose only web ports (Railway doesn't allow VNC direct access)
EXPOSE 6080

# Health check (Railway optimized)
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD /railway-health-check.sh

# Set the startup command (Railway optimized)
CMD ["/scripts/railway-optimized-start.sh"]