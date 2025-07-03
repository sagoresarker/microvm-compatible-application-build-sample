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

# Create .next directory with proper permissions
RUN mkdir -p .next

# Copy systemd service file
COPY nextjs-app.service /etc/systemd/system/nextjs-app.service

# Enable the service to start on boot
RUN systemctl enable nextjs-app.service

# Expose port
EXPOSE 3000

# Set environment variables
ENV NODE_ENV=production
ENV PORT=3000
ENV HOSTNAME="0.0.0.0"

# Use systemd as the init system
CMD ["/sbin/init"]