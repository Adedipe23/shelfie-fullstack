# GitHub Codespaces Deployment Guide

This guide explains how to deploy the ISMS application in GitHub Codespaces with optimized container networking to avoid CORS issues.

## 🚀 Quick Start

### Option 1: Docker Compose (Recommended)
1. Open this repository in GitHub Codespaces
2. Run the Codespaces startup script:
   ```bash
   ./scripts/codespaces-simple-start.sh
   ```
3. Wait for the setup to complete (2-3 minutes)
4. Access the application via the forwarded ports

### Option 2: Standalone Mode (Alternative)
If you encounter Docker-in-Docker issues, use standalone mode:
1. Open this repository in GitHub Codespaces
2. Run the standalone setup:
   ```bash
   ./scripts/codespaces-standalone-setup.sh
   ```
3. Start the application:
   ```bash
   ./scripts/start-codespaces-standalone.sh
   ```

### Option 3: Manual Docker Compose
1. Open this repository in GitHub Codespaces
2. Run the Docker Compose manually:
   ```bash
   docker compose -f docker-compose.codespaces.yml up -d --build
   ```

## 🏗️ Architecture Changes for Codespaces

### Internal Container Networking
The Codespaces configuration uses **internal container networking** to eliminate CORS issues:

- **Frontend → Backend**: `http://backend:8000` (internal Docker network)
- **No HAProxy dependency**: Direct container-to-container communication
- **CORS-free**: All API calls happen within the Docker network

### Environment Configuration
- **Environment File**: `.env.codespaces` (optimized for Codespaces)
- **Docker Compose**: `docker-compose.codespaces.yml` (internal networking)
- **Automatic Port Forwarding**: Codespaces handles external access

## 🌐 Accessing the Application

### Forwarded Ports
GitHub Codespaces automatically forwards these ports:

| Port | Service | URL Pattern |
|------|---------|-------------|
| 3000 | Frontend | `https://$CODESPACE_NAME-3000.preview.app.github.dev` |
| 8000 | Backend API | `https://$CODESPACE_NAME-8000.preview.app.github.dev` |
| 80 | HAProxy (optional) | `https://$CODESPACE_NAME-80.preview.app.github.dev` |
| 8404 | HAProxy Stats | `https://$CODESPACE_NAME-8404.preview.app.github.dev` |

### Login Credentials
- **Email**: `admin@test.com`
- **Password**: `admin123`

## 🔧 Configuration Files

### `.env.codespaces`
Optimized environment variables for Codespaces:
```bash
VITE_API_BASE_URL=http://backend:8000  # Internal networking
BACKEND_CORS_ORIGINS='["*"]'           # Allow all origins
CODESPACES=true                        # Codespaces flag
```

### `docker-compose.codespaces.yml`
- Uses `env_file: .env.codespaces`
- Internal container networking
- Optimized for Codespaces environment
- Optional HAProxy with profiles

### `.devcontainer/devcontainer.json`
- Automatic port forwarding
- VS Code extensions
- Post-create and post-start commands
- Docker-in-Docker support

## 🛠️ Development Commands

### Container Management
```bash
# Start services
docker compose -f docker-compose.codespaces.yml up -d

# View logs
docker compose -f docker-compose.codespaces.yml logs -f

# Restart services
docker compose -f docker-compose.codespaces.yml restart

# Stop services
docker compose -f docker-compose.codespaces.yml down

# View status
docker compose -f docker-compose.codespaces.yml ps
```

### Database Management
```bash
# Create admin user
docker exec isms-backend python manage.py create-superuser

# Check database
docker exec isms-backend python manage.py check-db

# Reset database
docker exec isms-backend python manage.py reset-db
```

## 🔍 Troubleshooting

### Docker-in-Docker Issues
If you encounter the error `env: can't execute 'bash': No such file or directory`:

**Problem**: The Alpine-based Node.js image doesn't have `bash` required by Docker-in-Docker feature.

**Solutions**:
1. **Use Standalone Mode** (Recommended):
   ```bash
   ./scripts/codespaces-standalone-setup.sh
   ./scripts/start-codespaces-standalone.sh
   ```

2. **Use Docker Outside of Docker**:
   ```bash
   ./scripts/codespaces-simple-start.sh
   ```

3. **Manual Docker Compose**:
   ```bash
   docker compose -f docker-compose.codespaces.yml up -d --build
   ```

### CORS Issues
If you encounter CORS issues:
1. Verify `VITE_API_BASE_URL=http://backend:8000` in `.env.codespaces`
2. Check that containers are on the same network
3. Restart the frontend service

### Port Forwarding Issues
1. Check Codespaces port forwarding in VS Code
2. Ensure ports are set to "Public" if needed
3. Try accessing via different port URLs

### Container Communication
```bash
# Test backend from frontend container
docker exec isms-frontend curl http://backend:8000/health

# Test network connectivity
docker network ls
docker network inspect isms-codespaces-network
```

## 📊 Monitoring

### Health Checks
```bash
# Backend health
curl https://$CODESPACE_NAME-8000.preview.app.github.dev/health

# Frontend health
curl https://$CODESPACE_NAME-3000.preview.app.github.dev
```

### Logs
```bash
# All services
docker compose -f docker-compose.codespaces.yml logs -f

# Specific service
docker compose -f docker-compose.codespaces.yml logs -f frontend
docker compose -f docker-compose.codespaces.yml logs -f backend
```

## 🔄 Switching Between Environments

### Local Development
```bash
./scripts/dev-start.sh
```

### Codespaces
```bash
./scripts/codespaces-start.sh
```

### Production
```bash
docker compose -f docker-compose.prod.yml up -d
```

## 📝 Notes

- **Internal Networking**: Eliminates CORS issues completely
- **Environment Isolation**: Separate configs for different environments
- **Hot Reload**: Fully functional in Codespaces
- **Debugging**: Python debugger available on port 5678
- **Database**: SQLite with persistent volumes
