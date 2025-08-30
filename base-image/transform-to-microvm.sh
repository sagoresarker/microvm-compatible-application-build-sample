#!/bin/bash

# Transform any JavaScript application to MicroVM-compatible format
set -e

echo "Transforming application to MicroVM-compatible format..."

# Set working directory
WORKDIR="/app"

# Function to configure Next.js application for MicroVM
configure_nextjs() {
    echo "Configuring Next.js application for MicroVM..."

    # The application is already built in the previous stage
    # We just need to configure it for MicroVM

    # Handle Next.js standalone builds
    if [ -f "server.js" ]; then
        echo "Next.js standalone build detected (server.js found)"
        # The standalone files are already in the root directory
        # Static files are already in .next/static
        # Public files are already in public/

        # Update systemd service for Next.js standalone
        cp /usr/local/share/nextjs-app.service /etc/systemd/system/app.service
        echo "Next.js standalone service configured"
    else
        echo "Next.js build found but no standalone server.js - using generic service"
        # Use the generic service for non-standalone builds
        cp /usr/local/share/app.service /etc/systemd/system/app.service
    fi
}

# Function to setup environment
setup_environment() {
    # Set environment variables
    export NODE_ENV=production
    export PORT=3000
    export HOSTNAME="0.0.0.0"

    # Enable the systemd service
    systemctl enable app.service

    echo "Environment setup complete"
}

# Main execution
cd "$WORKDIR"
configure_nextjs
setup_environment

echo "Transformation complete! Application is ready for MicroVM deployment."