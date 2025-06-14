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

# Enable multiarch for wine32 support
RUN dpkg --add-architecture i386

# Install system dependencies with proper wine32 support
RUN apt-get update && apt-get install -y \
    # Ultra-minimal desktop environment
    twm xterm \
    # VNC server
    tightvncserver \
    # noVNC for web access
    novnc websockify \
    # Wine with 32-bit support
    wine wine32 wine64 winetricks cabextract \
    # Wine dependencies
    winbind \
    # Essential utilities
    wget curl unzip iproute2 \
    # X11 utilities
    x11-utils x11-apps \
    # Audio support
    pulseaudio \
    # Fonts (including X11 fonts for VNC)
    fonts-liberation fonts-dejavu-core \
    xfonts-base xfonts-75dpi xfonts-100dpi \
    # Process management
    psmisc \
    # Health check utilities
    netcat-openbsd \
    # File management
    thunar \
    # Additional desktop utilities
    firefox \
    gedit \
    # Wine dependencies for 32-bit support
    libc6:i386 libncurses5:i386 libstdc++6:i386 \
    lib32z1 libbz2-1.0:i386 libasound2:i386 libfontconfig1:i386 \
    libfreetype6:i386 libxtst6:i386 libgtk-3-0:i386 \
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

# Create directories for logs and runtime data
RUN mkdir -p /var/log /var/run

# Copy essential scripts
COPY scripts/install-roblox.sh /opt/install-roblox.sh
COPY scripts/railway-health-check.sh /railway-health-check.sh
COPY scripts/railway-start.sh /scripts/railway-start.sh
COPY scripts/health-endpoint.sh /scripts/health-endpoint.sh
RUN chmod +x /opt/install-roblox.sh /railway-health-check.sh /scripts/railway-start.sh /scripts/health-endpoint.sh

# Note: Railway manages persistent storage - no VOLUME declarations needed

# Expose only web ports (Railway doesn't allow VNC direct access)
EXPOSE 6080

# Health check (Railway optimized)
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD /railway-health-check.sh

# Set the startup command (Railway optimized)
CMD ["/scripts/railway-start.sh"]