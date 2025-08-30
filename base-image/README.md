# MicroVM Base Image System

This system provides a base image and transformation process to convert any JavaScript application into a MicroVM-compatible Docker image.

## Overview

The MicroVM Base Image System consists of:

1. **Base Image** (`poridhi/poridhi-cloud-native-base:latest`) - Contains the MicroVM-compatible environment
2. **Transformation Script** - Automatically detects and configures different JavaScript frameworks
3. **Transformation Dockerfile** - Multi-stage build process to convert any app

## Supported Frameworks

- **Next.js** (with standalone builds)
- **React** (Vite, Create React App)
- **Vue.js** (Vue CLI, Vite)
- **Angular**
- **Generic Node.js** applications
- **Static sites** (HTML/CSS/JS)

## Quick Start

### 1. Build the Base Image

```bash
cd base-image
make build-base
```

### 2. Transform Your Application

Place the `transform.Dockerfile` in your application root and run:

```bash
make transform-app
```

### 3. Deploy to MicroVM

```bash
make build-and-push-app
```

## Detailed Usage

### Step 1: Build Base Image

The base image contains:
- `weaveworks/ignite-ubuntu:latest` base
- Node.js 18.x
- Systemd service configuration
- Automatic transformation script

```bash
cd base-image
make build-base
make push-base  # Push to registry
```

### Step 2: Transform Your Application

The transformation process:

1. **Detects** your application type (Next.js, React, Vue, etc.)
2. **Builds** the application using the original build process
3. **Configures** systemd service for auto-start
4. **Optimizes** for MicroVM environment

```bash
# From your application directory
make transform-app
```

### Step 3: Test Locally

```bash
make run-app
# Access at http://localhost:3000
```

### Step 4: Deploy

```bash
make build-and-push-app
```

## Framework-Specific Configuration

### Next.js Applications

The system automatically detects Next.js and:
- Enables standalone builds
- Copies static files to correct locations
- Configures systemd service for standalone mode

**Required**: Add `output: 'standalone'` to your `next.config.js`:

```javascript
/** @type {import('next').NextConfig} */
const nextConfig = {
  output: 'standalone',
}

module.exports = nextConfig
```

### React Applications

Supports:
- Create React App
- Vite-based React apps
- Custom React setups

### Vue.js Applications

Supports:
- Vue CLI
- Vite-based Vue apps
- Nuxt.js (with custom configuration)

### Angular Applications

Automatically detects Angular and runs `ng build`.

### Generic Node.js

For custom Node.js applications, the system:
- Installs dependencies
- Runs build script if available
- Creates generic systemd service

## Transformation Process Details

### Automatic Detection

The transformation script detects your application type by checking for:

- `next.config.js/ts` → Next.js
- `vite.config.js/ts` → Vite
- `angular.json` → Angular
- `vue.config.js` → Vue CLI
- `package.json` → Generic Node.js

### Build Process

1. **Dependencies**: Installs using yarn.lock, package-lock.json, or package.json
2. **Build**: Runs framework-specific build command
3. **Optimization**: Copies static files and configures paths
4. **Service Setup**: Creates and enables systemd service

### Systemd Service Configuration

The system creates appropriate systemd services:

**Generic Node.js:**
```ini
[Service]
WorkingDirectory=/app
ExecStart=/usr/bin/node /app/server.js
```

**Next.js Standalone:**
```ini
[Service]
WorkingDirectory=/app/.next/standalone
ExecStart=/usr/bin/node /app/.next/standalone/server.js
```

## Customization

### Custom Build Commands

If your application uses custom build commands, modify the transformation script:

```bash
# Edit base-image/Dockerfile
# Modify the detect_and_build() function
```

### Custom Port Configuration

Change the default port by modifying environment variables:

```dockerfile
ENV PORT=8080
```

### Custom Environment Variables

Add custom environment variables in the transformation script:

```bash
export CUSTOM_VAR="value"
```

## Troubleshooting

### Common Issues

1. **Build Failures**
   - Check Node.js version compatibility
   - Verify all dependencies are in package.json
   - Ensure build scripts are properly defined

2. **Static Files Not Loading**
   - For Next.js: Verify `output: 'standalone'` is set
   - Check that static files are copied to correct locations

3. **Service Not Starting**
   - Verify systemd service is enabled
   - Check application logs: `journalctl -u app.service`

4. **Port Not Accessible**
   - Ensure EXPOSE directive is set
   - Verify MicroVM port mapping

### Debugging

Enable verbose output:

```bash
# Add to transformation script
set -x
```

Check service status:

```bash
docker exec -it container_name systemctl status app.service
```

View application logs:

```bash
docker exec -it container_name journalctl -u app.service -f
```

## Advanced Usage

### Multi-Stage Builds

The transformation process supports complex multi-stage builds:

```dockerfile
# Your custom build stages
FROM node:18-alpine AS custom-build
# ... custom build logic

# Final MicroVM stage
FROM poridhi/poridhi-cloud-native-base:latest AS microvm
COPY --from=custom-build /app /app
RUN /usr/local/bin/transform-to-microvm
```

### Custom Base Image

Extend the base image for your specific needs:

```dockerfile
FROM poridhi/poridhi-cloud-native-base:latest

# Add custom packages
RUN apt-get update && apt-get install -y \
    your-custom-package

# Custom configuration
COPY custom-config /etc/custom-config
```

## Best Practices

1. **Always use the base image** for MicroVM compatibility
2. **Test locally** before deploying to production
3. **Use specific tags** for production deployments
4. **Monitor logs** for application health
5. **Keep base image updated** for security patches

## Contributing

To add support for new frameworks:

1. Modify the `detect_and_build()` function in the base image
2. Add framework-specific detection logic
3. Implement appropriate build and configuration steps
4. Test with sample applications

## License

This project is part of the Poridhi Cloud MicroVM system.