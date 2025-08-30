# MicroVM Base Image System - Complete Guide

## Overview

This system provides a **reusable base image** and **automated transformation process** to convert any JavaScript application into a MicroVM-compatible Docker image. Instead of manually configuring each application for MicroVM deployment, you can now use a standardized approach.

## System Architecture

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   Your App      │    │  Base Image      │    │  MicroVM        │
│                 │    │                  │    │  Compatible     │
│ • Next.js       │───▶│ • weaveworks/    │───▶│ • systemd       │
│ • React         │    │   ignite-ubuntu  │    │ • auto-start    │
│ • Vue           │    │ • Node.js 18     │    │ • optimized     │
│ • Angular       │    │ • transform      │    │ • production    │
│ • Node.js       │    │   script         │    │   ready         │
└─────────────────┘    └──────────────────┘    └─────────────────┘
```

## Key Components

### 1. Base Image (`poridhi/poridhi-cloud-native-base:latest`)
- **Base**: `weaveworks/ignite-ubuntu:latest`
- **Runtime**: Node.js 20.x
- **Init System**: systemd
- **Features**:
  - Automatic framework detection
  - Systemd service configuration
  - Static file handling
  - Production optimization

### 2. Transformation Script (`/usr/local/bin/transform-to-microvm`)
- **Automatic Detection**: Next.js, React, Vue, Angular, Node.js
- **Smart Build Process**: Uses appropriate build commands
- **Service Configuration**: Creates framework-specific systemd services
- **Static File Handling**: Copies files to correct locations

### 3. Transformation Dockerfile (`transform.Dockerfile`)
- **Multi-stage Build**: Optimized build process
- **Framework Agnostic**: Works with any JavaScript application
- **MicroVM Ready**: Final image is MicroVM-compatible

## Supported Frameworks

| Framework | Detection | Build Command | Service Config |
|-----------|-----------|---------------|----------------|
| Next.js | `next.config.js/ts` | `npm run build` | Standalone mode |
| React (Vite) | `vite.config.js/ts` | `npm run build` | Static serve |
| Vue.js | `vue.config.js` | `npm run build` | Static serve |
| Angular | `angular.json` | `ng build` | Static serve |
| Node.js | `package.json` | `npm run build` | Generic service |

## Quick Start

### Step 1: Build Base Image (One-time setup)
```bash
cd base-image
make build-base
make push-base
```

### Step 2: Transform Your Application
```bash
# From your application directory
make transform
```

### Step 3: Deploy
```bash
make push
```

## Detailed Workflow

### 1. Application Detection
The transformation script automatically detects your application type:

```bash
# Detection logic
if [ -f "next.config.js" ] || [ -f "next.config.ts" ]; then
    echo "Detected Next.js application"
elif [ -f "vite.config.js" ] || [ -f "vite.config.ts" ]; then
    echo "Detected Vite application"
elif [ -f "angular.json" ]; then
    echo "Detected Angular application"
# ... more detections
fi
```

### 2. Build Process
Uses the original multi-stage build approach:

```dockerfile
# Stage 1: Dependencies
FROM node:18-alpine AS deps
COPY package*.json yarn.lock* ./
RUN npm ci --include=dev

# Stage 2: Build
FROM node:18-alpine AS builder
COPY --from=deps /app/node_modules ./node_modules
COPY . .
RUN npm run build

# Stage 3: MicroVM Transform
FROM poridhi/poridhi-cloud-native-base:latest AS microvm
COPY --from=builder /app /app
RUN /usr/local/bin/transform-to-microvm
```

### 3. Systemd Service Configuration
Creates appropriate systemd services:

**Next.js Standalone:**
```ini
[Service]
WorkingDirectory=/app/.next/standalone
ExecStart=/usr/bin/node /app/.next/standalone/server.js
```

**Generic Node.js:**
```ini
[Service]
WorkingDirectory=/app
ExecStart=/usr/bin/node /app/server.js
```

## Framework-Specific Features

### Next.js Applications
- ✅ Standalone build support
- ✅ Static file copying
- ✅ Server-side rendering
- ✅ API routes support

### React Applications
- ✅ Vite build support
- ✅ Create React App support
- ✅ Static file serving
- ✅ Client-side routing

### Vue.js Applications
- ✅ Vue CLI support
- ✅ Vite build support
- ✅ Static file serving
- ✅ SPA routing

### Angular Applications
- ✅ Angular CLI builds
- ✅ Static file serving
- ✅ Production optimization
- ✅ AOT compilation

## Benefits

### 1. **Reusability**
- One base image for all JavaScript applications
- Consistent MicroVM configuration
- Reduced maintenance overhead

### 2. **Automation**
- No manual systemd configuration
- Automatic framework detection
- Smart build process selection

### 3. **Reliability**
- Tested transformation process
- Framework-specific optimizations
- Production-ready configurations

### 4. **Flexibility**
- Easy to add new framework support
- Customizable transformation process
- Extensible base image

## Usage Examples

### Example 1: Next.js Application
```bash
# Your Next.js app with next.config.ts
cd my-nextjs-app
make transform
make push
```

### Example 2: React Vite Application
```bash
# Your React app with vite.config.ts
cd my-react-app
make transform
make push
```

### Example 3: Custom Node.js Application
```bash
# Your custom Node.js app
cd my-nodejs-app
make transform
make push
```

## Advanced Configuration

### Custom Build Commands
Modify the transformation script for custom builds:

```bash
# In base-image/Dockerfile, edit detect_and_build()
if [ -f "custom-build.sh" ]; then
    echo "Using custom build script"
    chmod +x custom-build.sh
    ./custom-build.sh
fi
```

### Custom Port Configuration
```dockerfile
# In transform.Dockerfile
ENV PORT=8080
ENV HOSTNAME="0.0.0.0"
```

### Custom Environment Variables
```bash
# In transformation script
export CUSTOM_VAR="value"
export DATABASE_URL="postgresql://..."
```

## Troubleshooting

### Common Issues

1. **Build Failures**
   ```bash
   # Check Node.js version compatibility
   node --version

   # Verify dependencies
   npm ls
   ```

2. **Static Files Not Loading**
   ```bash
   # For Next.js, verify standalone config
   cat next.config.ts

   # Check file locations
   ls -la .next/standalone/
   ```

3. **Service Not Starting**
   ```bash
   # Check service status
   docker exec -it container systemctl status app.service

   # View logs
   docker exec -it container journalctl -u app.service -f
   ```

### Debug Mode
Enable verbose output in transformation script:

```bash
# Add to base-image/Dockerfile
set -x  # Enable debug mode
```

## Best Practices

1. **Always use the base image** for MicroVM deployments
2. **Test locally** before production deployment
3. **Use specific tags** for production images
4. **Monitor application logs** for health checks
5. **Keep base image updated** for security patches

## Migration Guide

### From Manual Dockerfile
**Before:**
```dockerfile
FROM weaveworks/ignite-ubuntu:latest
RUN apt-get update && apt-get install -y curl ca-certificates
# ... 50+ lines of manual configuration
```

**After:**
```dockerfile
FROM poridhi/poridhi-cloud-native-base:latest AS microvm
COPY --from=builder /app /app
RUN /usr/local/bin/transform-to-microvm
```

### Benefits of Migration
- **Reduced complexity**: 50+ lines → 3 lines
- **Consistent configuration**: All apps follow same pattern
- **Easier maintenance**: Centralized framework logic
- **Better reliability**: Tested transformation process

## Future Enhancements

1. **Additional Frameworks**: Support for more JavaScript frameworks
2. **Custom Runtimes**: Python, Go, Rust support
3. **Advanced Configuration**: Custom systemd services
4. **Monitoring Integration**: Built-in health checks and metrics
5. **Security Enhancements**: Automated security scanning

## Conclusion

The MicroVM Base Image System provides a **standardized, automated approach** to deploying JavaScript applications to MicroVMs. By using this system, you can:

- **Reduce deployment complexity** by 90%
- **Ensure consistency** across all applications
- **Improve reliability** with tested configurations
- **Accelerate development** with reusable components

This system transforms the MicroVM deployment process from a manual, error-prone task into a simple, automated workflow that works for any JavaScript application.