# ISMS - Inventory and Sales Management System

A modern, containerized web application for inventory and sales management, built with React (frontend) and FastAPI (backend).

## 🏗️ Architecture

This application has been transformed from a Tauri desktop application to a containerized web application:

- **Frontend**: React + TypeScript + Vite + Tailwind CSS
- **Backend**: FastAPI + Python + SQLAlchemy + SQLite
- **Proxy**: HAProxy for load balancing and routing
- **Containerization**: Docker + Docker Compose

## 🚀 Quick Start

### Prerequisites

- Docker (20.10+)
- Docker Compose (2.0+)
- Git

### Development Environment

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd shelfi-dockerized
   ```

2. **Start the development environment**
   ```bash
   chmod +x scripts/*.sh
   ./scripts/dev-start.sh
   ```

3. **Access the application**
   - Main Application: http://localhost
   - Frontend (direct): http://localhost:3000
   - Backend API: http://localhost:8000
   - HAProxy Stats: http://localhost:8404/stats (admin/admin123)

### Management Scripts

- **Start environment**: `./scripts/dev-start.sh`
- **Stop environment**: `./scripts/dev-stop.sh`
- **View logs**: `./scripts/dev-logs.sh [service]`
- **Restart services**: `./scripts/dev-restart.sh [service]`

## 📁 Project Structure

```
shelfi-dockerized/
├── new-isms-frontend/          # React frontend application
│   ├── src/                    # Source code
│   ├── public/                 # Static assets
│   ├── Dockerfile              # Multi-stage Docker build
│   ├── nginx.conf              # Production nginx config
│   └── package.json            # Dependencies and scripts
├── isms-backend/               # FastAPI backend application
│   ├── app/                    # Application code
│   ├── Dockerfile              # Production Docker build
│   ├── Dockerfile.dev          # Development Docker build
│   └── requirements.txt        # Python dependencies
├── haproxy/                    # Load balancer configuration
│   ├── haproxy.cfg             # HAProxy configuration
│   └── Dockerfile              # HAProxy Docker build
├── scripts/                    # Development scripts
│   ├── dev-start.sh            # Start development environment
│   ├── dev-stop.sh             # Stop development environment
│   ├── dev-logs.sh             # View service logs
│   └── dev-restart.sh          # Restart services
├── docker-compose.dev.yml      # Development environment
├── docker-compose.prod.yml     # Production environment
├── .env.development            # Development environment variables
└── .env.production.template    # Production environment template
```

## 🔧 Development

### Hot Reload

The development environment supports hot reload for both frontend and backend:

- **Frontend**: Vite HMR (Hot Module Replacement)
- **Backend**: Uvicorn auto-reload

### Environment Variables

Development environment variables are configured in:
- `.env.development` (global)
- `new-isms-frontend/.env.development` (frontend-specific)
- `isms-backend/.env.development` (backend-specific)

### Debugging

- **Frontend**: React DevTools, browser debugging
- **Backend**: Python debugger on port 5678

### Database

The development environment uses SQLite by default. The database file is persisted in a Docker volume.

## 🚢 Production Deployment

### Environment Setup

1. **Copy environment template**
   ```bash
   cp .env.production.template .env.production
   ```

2. **Configure production variables**
   Edit `.env.production` with your production values:
   - Change `SECRET_KEY`
   - Set proper `VITE_API_BASE_URL`
   - Configure CORS origins
   - Set up SSL certificates (if needed)

3. **Deploy with Docker Compose**
   ```bash
   docker-compose -f docker-compose.prod.yml up -d
   ```

### Production Features

- **Security**: Rate limiting, CORS, security headers
- **Performance**: Nginx static file serving, gzip compression
- **Monitoring**: Health checks, HAProxy stats
- **Scalability**: Load balancing ready

## 🔍 Monitoring

### Health Checks

All services include health checks:
- **Frontend**: `/health` endpoint
- **Backend**: `/health` endpoint  
- **Proxy**: HAProxy configuration validation

### Logs

View logs using the provided scripts:
```bash
./scripts/dev-logs.sh           # All services
./scripts/dev-logs.sh frontend  # Frontend only
./scripts/dev-logs.sh -f backend # Follow backend logs
```

### HAProxy Stats

Access HAProxy statistics at http://localhost:8404/stats
- Username: `admin`
- Password: `admin123`

## 🛠️ Troubleshooting

### Common Issues

1. **Port conflicts**
   - Check if ports 80, 3000, 8000 are available
   - Modify port mappings in docker-compose.dev.yml if needed

2. **Permission issues**
   - Ensure scripts are executable: `chmod +x scripts/*.sh`
   - Check Docker permissions

3. **Service not starting**
   - Check logs: `./scripts/dev-logs.sh [service]`
   - Verify environment variables
   - Ensure Docker has enough resources

### Reset Environment

To completely reset the development environment:
```bash
./scripts/dev-stop.sh --clean    # Remove containers and volumes
./scripts/dev-start.sh --pull    # Pull latest images and restart
```

## 📝 API Documentation

When the backend is running, API documentation is available at:
- Swagger UI: http://localhost:8000/docs
- ReDoc: http://localhost:8000/redoc

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test in the development environment
5. Submit a pull request

## 📄 License

[Add your license information here]
