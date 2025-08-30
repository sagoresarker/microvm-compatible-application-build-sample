# Multi-stage Dockerfile for Next.js production deployment
# Optimized for microVM environments

# Stage 1: Dependencies installation
FROM node:20-alpine AS deps
RUN apk add --no-cache libc6-compat

WORKDIR /app

# Copy package files
COPY package*.json yarn.lock* ./

# Install dependencies with exact versions for reproducible builds
RUN \
  if [ -f yarn.lock ]; then yarn install --frozen-lockfile --production=false; \
  elif [ -f package-lock.json ]; then npm ci --include=dev; \
  else echo "Warning: Lockfile not found. Installing from package.json" && npm install; \
  fi

# Stage 2: Build the application
FROM node:20-alpine AS builder
WORKDIR /app

# Copy dependencies from deps stage
COPY --from=deps /app/node_modules ./node_modules

# Copy source code
COPY . .

# Copy production environment variables
COPY prod.env .env.production 2>/dev/null || true

# Set environment variables for build
ENV NODE_ENV=production
ENV NEXT_TELEMETRY_DISABLED=1

# Build the application
RUN \
  if [ -f yarn.lock ]; then yarn build; \
  elif [ -f package-lock.json ]; then npm run build; \
  else npm run build; \
  fi

# Stage 3: Transform to MicroVM-compatible format
FROM poridhi/poridhi-cloud-native-base:v0.0.2 AS microvm

# Copy built application (matching your original structure)
COPY --from=builder /app/public ./public
COPY --from=builder /app/.next/standalone ./
COPY --from=builder /app/.next/static ./.next/static

# Run the transformation script to make it MicroVM-compatible
RUN /usr/local/bin/transform-to-microvm

# The base image already has the correct CMD and environment setup
# No need to override as it uses systemd init system