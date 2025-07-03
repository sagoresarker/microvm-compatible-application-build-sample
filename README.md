# Docker Setup for MicroVM Compatibility - Poridhi Cloud

This guide explains how to set up Docker images for running JavaScript applications in MicroVMs using Poridhi Cloud.

## Overview

MicroVMs require specific Docker configurations to run applications properly. This setup ensures your JavaScript applications (Next.js, React, Vue, Angular, etc.) start automatically when the MicroVM boots.

## Prerequisites

- Docker installed on your system
- A JavaScript application with a build process
- Basic knowledge of systemd services

## Dockerfile Structure

### 1. Base Image
Always use the official Ubuntu base image for MicroVM compatibility:

```dockerfile
FROM weaveworks/ignite-ubuntu:latest
```

### 2. Install Node.js
Install Node.js 18 and required dependencies:

```dockerfile
RUN apt-get update && apt-get install -y \
    curl \
    ca-certificates \
    && curl -fsSL https://deb.nodesource.com/setup_18.x | bash - \
    && apt-get install -y nodejs \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*
```

### 3. Copy Application Files
Copy your entire application to the container:

```dockerfile
WORKDIR /app
COPY . .
```

### 4. Build Application
Install dependencies and build your application:

```dockerfile
RUN npm ci
RUN npm run build
```

### 5. Configure for Standalone Builds (Next.js)
For Next.js applications with `output: 'standalone'`, copy static files:

```dockerfile
RUN cp -r .next/static .next/standalone/.next/static
RUN cp -r public .next/standalone/public
```

### 6. Setup Systemd Service
Create and enable a systemd service for auto-start:

```dockerfile
COPY app-service.service /etc/systemd/system/app-service.service
RUN systemctl enable app-service.service
```

### 7. Final Configuration
Set environment variables and use systemd as init:

```dockerfile
EXPOSE 3000
ENV NODE_ENV=production
ENV PORT=3000
ENV HOSTNAME="0.0.0.0"
CMD ["/sbin/init"]
```

## Systemd Service Configuration

Create a service file (e.g., `app-service.service`) for your application:

```ini
[Unit]
Description=JavaScript Application
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/app
ExecStart=/usr/bin/node /app/server.js
Restart=always
RestartSec=10
Environment=NODE_ENV=production
Environment=PORT=3000
Environment=HOSTNAME=0.0.0.0

[Install]
WantedBy=multi-user.target
```

### For Next.js Standalone Builds:
```ini
[Unit]
Description=Next.js Application
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/app/.next/standalone
ExecStart=/usr/bin/node /app/.next/standalone/server.js
Restart=always
RestartSec=10
Environment=NODE_ENV=production
Environment=PORT=3000
Environment=HOSTNAME=0.0.0.0

[Install]
WantedBy=multi-user.target
```

## Complete Example Dockerfile

```dockerfile
# Use weaveworks/ignite-ubuntu as base image
FROM weaveworks/ignite-ubuntu:latest

# Install Node.js and npm
RUN apt-get update && apt-get install -y \
    curl \
    ca-certificates \
    && curl -fsSL https://deb.nodesource.com/setup_18.x | bash - \
    && apt-get install -y nodejs \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Copy all project files
COPY . .

# Install dependencies
RUN npm ci

# Build the application
RUN npm run build

# For Next.js standalone builds - copy static files
RUN cp -r .next/static .next/standalone/.next/static
RUN cp -r public .next/standalone/public

# Copy systemd service file
COPY app-service.service /etc/systemd/system/app-service.service

# Enable the service to start on boot
RUN systemctl enable app-service.service

# Expose port
EXPOSE 3000

# Set environment variables
ENV NODE_ENV=production
ENV PORT=3000
ENV HOSTNAME="0.0.0.0"

# Use systemd as the init system
CMD ["/sbin/init"]
```

## Build and Deploy

1. **Build your Docker image:**
   ```bash
   docker build -t your-app-name:latest .
   ```

2. **Push to registry:**
   ```bash
   docker push your-registry/your-app-name:latest
   ```

3. **Deploy to Poridhi Cloud:**
   Create a MicroVM configuration file and deploy using Poridhi Cloud platform.

## Key Points for MicroVM Compatibility

1. **Always use `weaveworks/ignite-ubuntu:latest`** as the base image
2. **Use systemd services** for automatic application startup
3. **Run as root user** in MicroVM environment
4. **Copy static files** for standalone builds
5. **Set proper environment variables** for production
6. **Use `/sbin/init`** as the CMD for proper systemd initialization

## Troubleshooting

- **404 errors for static files**: Ensure static files are copied to the correct location
- **Application not starting**: Check systemd service configuration and enable status
- **Port not accessible**: Verify EXPOSE directive and MicroVM port mapping
- **Build failures**: Check Node.js version compatibility and dependency installation

## Framework-Specific Notes

- **Next.js**: Use `output: 'standalone'` in `next.config.js`
- **React**: Ensure build output is correctly served
- **Vue**: Configure for production build serving
- **Angular**: Set up proper build and serve commands

This setup ensures your JavaScript applications run reliably in MicroVMs with automatic startup and proper resource management.
