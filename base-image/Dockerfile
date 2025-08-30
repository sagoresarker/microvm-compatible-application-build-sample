# Base image for MicroVM-compatible JavaScript applications
FROM weaveworks/ignite-ubuntu:latest

# Install Node.js and npm
RUN apt-get update && apt-get install -y \
    curl \
    ca-certificates \
    && curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y nodejs \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Create application directory
WORKDIR /app

# Copy systemd service files
COPY app.service /etc/systemd/system/app.service
COPY nextjs-app.service /usr/local/share/nextjs-app.service

# Copy transformation script
COPY transform-to-microvm.sh /usr/local/bin/transform-to-microvm

# Make the transformation script executable
RUN chmod +x /usr/local/bin/transform-to-microvm

# Expose port
EXPOSE 3000

# Set environment variables
ENV NODE_ENV=production
ENV PORT=3000
ENV HOSTNAME="0.0.0.0"

# Use systemd as the init system
CMD ["/sbin/init"]