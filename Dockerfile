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

# Copy static files and public assets to standalone directory
# This is crucial for Next.js standalone builds to serve static content
RUN cp -r .next/static .next/standalone/.next/static
RUN cp -r public .next/standalone/public

# List files to verify the copy was successful (for debugging)
RUN ls -la .next/standalone/
RUN ls -la .next/standalone/.next/
RUN ls -la .next/standalone/public/

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