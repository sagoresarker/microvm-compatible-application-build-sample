# 🚀 MicroVM Setup Guide - Step by Step

## ❌ **Issues Fixed**

1. **Image Name Mismatch** - Fixed `poridhi/poridhi-cloud-native-base` → `poridhi/microvm-base`
2. **Node.js Version** - Upgraded from Node.js 18 → Node.js 20
3. **Missing prod.env** - Made the copy optional
4. **Husky Issue** - Added `--ignore-scripts` flag to skip prepare scripts

## 📋 **Step-by-Step Process**

### **Step 1: Build Base Image (One-time)**
```bash
cd base-image
make build-base
```

**What happens:**
- Creates `poridhi/microvm-base:latest` image
- Installs Node.js 20.x
- Sets up systemd services
- Copies transformation script

### **Step 2: Push Base Image (One-time)**
```bash
make push-base
```

**What happens:**
- Pushes base image to Docker registry
- Makes it available for other projects

### **Step 3: Transform Your Application**
```bash
cd ..  # Go back to your app directory
make transform
```

**What happens:**
1. **Stage 1 (deps)**: Installs dependencies with `--ignore-scripts`
2. **Stage 2 (builder)**: Builds your application
3. **Stage 3 (microvm)**: Transforms to MicroVM format

### **Step 4: Test Locally**
```bash
make run-app
```

### **Step 5: Deploy**
```bash
make push
```

## 🔧 **How the Transformation Works**

### **The `RUN /usr/local/bin/transform-to-microvm` Command**

This line runs the transformation script that:

1. **Configures Next.js application** for MicroVM environment

2. **Sets up systemd service** for auto-start

3. **Handles standalone builds** by detecting `server.js` in root

4. **Configures static files** (`.next/static` and `public/`)

5. **Enables the service** to start automatically

## 📁 **File Locations in the Base Image**

```
/usr/local/bin/transform-to-microvm          # Transformation script
/etc/systemd/system/app.service              # Generic systemd service
/usr/local/share/nextjs-app.service          # Next.js specific service
```

## 🎯 **For Your Specific Project**

Since your project has:
- Node.js 20+ dependencies
- Husky prepare scripts
- Semantic release tools

The transformation script will:
1. Skip husky installation with `--ignore-scripts`
2. Use Node.js 20 for compatibility
3. Handle the build process properly

## 🚨 **Common Issues & Solutions**

### **Issue: "husky: not found"**
**Solution:** Added `--ignore-scripts` flag to skip prepare scripts

### **Issue: "Node.js version incompatible"**
**Solution:** Upgraded base image to Node.js 20

### **Issue: "prod.env not found"**
**Solution:** Made the copy optional with `2>/dev/null || true`

### **Issue: "Base image not found"**
**Solution:** Fixed image name to `poridhi/microvm-base:latest`

## 🔄 **Complete Workflow**

```bash
# 1. Build base image (one-time setup)
cd base-image
make build-base
make push-base

# 2. Transform your application
cd ..
make transform

# 3. Test and deploy
make run-app
make push
```

## ✅ **What You Get**

After transformation, your app will:
- ✅ Run in MicroVM environment
- ✅ Start automatically with systemd
- ✅ Handle static files correctly
- ✅ Work with Node.js 20+ dependencies
- ✅ Skip problematic prepare scripts

The transformation process is now robust and handles all the edge cases in your project!