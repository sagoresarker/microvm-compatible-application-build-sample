# Example: Transforming Your Next.js Application

This example shows how to transform your current Next.js application using the MicroVM Base Image System.

## Current Setup

Your application already has:
- ✅ Next.js with `output: 'standalone'` configured
- ✅ Proper package.json with build scripts
- ✅ Static files in public directory

## Step 1: Build the Base Image

First, build the MicroVM-compatible base image:

```bash
cd base-image
make build-base
```

## Step 2: Transform Your Application

From your application root directory, run:

```bash
make transform-app
```

This will:
1. Use the original multi-stage build process
2. Copy the built application to the MicroVM base image
3. Run the transformation script to configure systemd
4. Create a MicroVM-compatible image

## Step 3: Test Locally

```bash
make run-app
```

Access your application at `http://localhost:3000`

## Step 4: Deploy

```bash
make build-and-push-app
```

## What Happens During Transformation

### 1. Application Detection
The transformation script detects your Next.js application by finding `next.config.ts`

### 2. Build Process
- Installs dependencies using `npm ci`
- Runs `npm run build`
- Creates `.next/standalone` directory

### 3. Static File Handling
- Copies `.next/static` to `.next/standalone/.next/static`
- Copies `public` directory to `.next/standalone/public`

### 4. Systemd Configuration
Creates a systemd service for Next.js standalone:

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

### 5. Auto-Start Configuration
Enables the systemd service to start automatically when the MicroVM boots.

## Comparison: Before vs After

### Before (Original Dockerfile)
```dockerfile
FROM weaveworks/ignite-ubuntu:latest
# Manual Node.js installation
# Manual dependency installation
# Manual build process
# Manual static file copying
# Manual systemd service setup
```

### After (Using Base Image System)
```dockerfile
# Stage 1: Build (using original process)
FROM node:18-alpine AS deps
# ... dependency installation

FROM node:18-alpine AS builder
# ... application build

# Stage 2: Transform to MicroVM
FROM poridhi/poridhi-cloud-native-base:latest AS microvm
COPY --from=builder /app /app
RUN /usr/local/bin/transform-to-microvm
```

## Benefits

1. **Reusability**: The base image can be used for any JavaScript application
2. **Consistency**: All MicroVM deployments follow the same pattern
3. **Maintainability**: Framework-specific logic is centralized
4. **Flexibility**: Easy to add support for new frameworks
5. **Reliability**: Tested transformation process for each framework

## Next Steps

1. **Build the base image** once and reuse for all applications
2. **Transform your applications** using the `transform.Dockerfile`
3. **Deploy to MicroVMs** with confidence in the configuration
4. **Extend the system** to support additional frameworks as needed

## Troubleshooting

If you encounter issues:

1. **Check the transformation logs**:
   ```bash
   docker logs container_name
   ```

2. **Verify the systemd service**:
   ```bash
   docker exec -it container_name systemctl status app.service
   ```

3. **Check application logs**:
   ```bash
   docker exec -it container_name journalctl -u app.service -f
   ```

The transformation process is designed to be robust and provide clear feedback about what's happening at each step.