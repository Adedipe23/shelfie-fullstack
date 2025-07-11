# GitHub Codespaces Troubleshooting Guide

This guide addresses common issues when deploying ISMS in GitHub Codespaces.

## 🚨 Common Issues and Solutions

### 1. Docker-in-Docker Build Failure

**Error Message**:
```
env: can't execute 'bash': No such file or directory
ERROR: Feature "Docker (Docker-in-Docker)" failed to install!
```

**Root Cause**: 
The Alpine-based Node.js image (`node:20-alpine`) doesn't include `bash`, which is required by the Docker-in-Docker devcontainer feature.

**Solutions** (in order of preference):

#### Solution A: Use Standalone Mode (Recommended)
Run the application natively without Docker containers:

```bash
# Setup
./scripts/codespaces-standalone-setup.sh

# Start application
./scripts/start-codespaces-standalone.sh
```

**Pros**: 
- No Docker complexity
- Faster startup
- Native development experience
- Full debugging capabilities

**Cons**: 
- Requires manual dependency management
- Different from production environment

#### Solution B: Use Docker Outside of Docker
Use the host Docker daemon from within the devcontainer:

```bash
./scripts/codespaces-simple-start.sh
```

**Pros**: 
- Uses Docker Compose
- Closer to production environment
- Container isolation

**Cons**: 
- Requires Docker outside of Docker feature
- More complex setup

#### Solution C: Manual Docker Compose
Run Docker Compose manually after Codespaces starts:

```bash
docker compose -f docker-compose.codespaces.yml up -d --build
```

**Pros**: 
- Full container environment
- Production-like setup

**Cons**: 
- Manual startup required
- Potential permission issues

### 2. Port Forwarding Issues

**Problem**: Cannot access application URLs

**Solutions**:
1. Check port forwarding in VS Code:
   - Go to "Ports" tab
   - Ensure ports 3000 and 8000 are forwarded
   - Set visibility to "Public" if needed

2. Use correct URLs:
   ```
   Frontend: https://$CODESPACE_NAME-3000.preview.app.github.dev
   Backend:  https://$CODESPACE_NAME-8000.preview.app.github.dev
   ```

3. Wait for services to fully start (2-3 minutes)

### 3. CORS Issues

**Problem**: Frontend cannot communicate with backend

**Solutions**:
1. Verify environment variables:
   ```bash
   # Check frontend API URL
   echo $VITE_API_BASE_URL
   
   # Should be: http://backend:8000 (for containers)
   # Or: http://localhost:8000 (for standalone)
   ```

2. Check backend CORS settings:
   ```bash
   # In .env.codespaces
   BACKEND_CORS_ORIGINS='["*"]'
   ```

3. Restart services:
   ```bash
   docker compose -f docker-compose.codespaces.yml restart
   ```

### 4. Database Issues

**Problem**: Database not initialized or user doesn't exist

**Solutions**:
1. Initialize database:
   ```bash
   # For containers
   docker exec isms-backend python manage.py init-db
   
   # For standalone
   cd isms-backend && python manage.py init-db
   ```

2. Create admin user:
   ```bash
   # For containers
   docker exec -it isms-backend python manage.py create-superuser
   
   # For standalone
   cd isms-backend && python manage.py create-superuser
   ```

### 5. Environment Variable Issues

**Problem**: Environment variables not loading correctly

**Solutions**:
1. Check environment file exists:
   ```bash
   ls -la .env.codespaces
   ```

2. Verify Docker Compose configuration:
   ```bash
   # Check if env_file is specified
   grep -A 5 "env_file" docker-compose.codespaces.yml
   ```

3. Manually export variables:
   ```bash
   export $(cat .env.codespaces | xargs)
   ```

## 🔧 Debugging Commands

### Check Service Status
```bash
# Docker Compose
docker compose -f docker-compose.codespaces.yml ps

# Standalone
ps aux | grep -E "(uvicorn|npm)"
```

### View Logs
```bash
# Docker Compose
docker compose -f docker-compose.codespaces.yml logs -f

# Standalone
# Check terminal outputs where services are running
```

### Test Connectivity
```bash
# Test backend health
curl http://localhost:8000/health

# Test frontend
curl http://localhost:3000

# Test internal networking (containers only)
docker exec isms-frontend wget -qO- http://backend:8000/health
```

### Reset Environment
```bash
# Stop all services
docker compose -f docker-compose.codespaces.yml down --volumes

# Remove containers and images
docker system prune -a

# Restart Codespace
# Use VS Code Command Palette: "Codespaces: Rebuild Container"
```

## 📋 Quick Reference

### File Locations
- Main config: `.devcontainer/devcontainer.json`
- Environment: `.env.codespaces`
- Docker Compose: `docker-compose.codespaces.yml`
- Scripts: `scripts/codespaces-*.sh`

### Key URLs
- Frontend: Port 3000
- Backend: Port 8000
- Health Check: `/health`
- API Docs: `/docs`

### Default Credentials
- Email: `admin@test.com`
- Password: `admin123`

## 🆘 Getting Help

If none of these solutions work:

1. **Check Codespaces logs**: VS Code → View → Output → Codespaces
2. **Rebuild container**: Command Palette → "Codespaces: Rebuild Container"
3. **Try different approach**: Switch between Docker and Standalone modes
4. **Check GitHub status**: https://www.githubstatus.com/
5. **Create new Codespace**: Sometimes a fresh start helps

## 📝 Reporting Issues

When reporting issues, please include:
- Error messages (full stack trace)
- Codespace configuration used
- Steps to reproduce
- Browser and OS information
- Screenshots if applicable
