#!/bin/bash

# ISMS GitHub Codespaces Standalone Setup Script
# This script sets up the ISMS application to run natively in Codespaces

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_status "Setting up ISMS for GitHub Codespaces (Standalone Mode)..."

# Install Python dependencies for backend
print_status "Installing Python dependencies..."
cd isms-backend
pip install -r requirements.txt
cd ..

# Install Node.js dependencies for frontend
print_status "Installing Node.js dependencies..."
cd new-isms-frontend
npm install
cd ..

# Create environment file for standalone mode
print_status "Creating standalone environment configuration..."
cat > .env.codespaces-standalone << EOF
# GitHub Codespaces Standalone Environment Configuration
NODE_ENV=development
VITE_API_BASE_URL=http://localhost:8000
VITE_APP_NAME="ISMS Codespaces"
VITE_APP_VERSION=0.1.0
VITE_ENABLE_DEVTOOLS=true
VITE_ENABLE_DEBUG_LOGS=true

# Backend Configuration
ENV_MODE=development
DATABASE_URL=sqlite:///./data/isms.db
SECRET_KEY=codespaces-standalone-secret-key
ACCESS_TOKEN_EXPIRE_MINUTES=60
REFRESH_TOKEN_EXPIRE_DAYS=7
BACKEND_CORS_ORIGINS='["http://localhost:3000", "http://127.0.0.1:3000", "*"]'
RATE_LIMIT_REQUESTS=1000
RATE_LIMIT_WINDOW=60
LOG_LEVEL=DEBUG
LOG_FORMAT=detailed
API_V1_STR=/api/v1
PROJECT_NAME="ISMS API"
DESCRIPTION="Inventory and Sales Management System API"
VERSION=0.1.0

# Python Configuration
PYTHONPATH=/workspaces/\${localWorkspaceFolderBasename}/isms-backend
PYTHONUNBUFFERED=1
PYTHONDONTWRITEBYTECODE=1
DEBUG=true
EOF

# Create startup scripts
print_status "Creating startup scripts..."

# Backend startup script
cat > scripts/start-backend-standalone.sh << 'EOF'
#!/bin/bash
cd isms-backend
export $(cat ../.env.codespaces-standalone | xargs)
python manage.py init-db
python manage.py create-superuser --email admin@test.com --password admin123 --full-name "Admin User" --role admin --superuser || true
python -m uvicorn main:app --host 0.0.0.0 --port 8000 --reload
EOF

# Frontend startup script
cat > scripts/start-frontend-standalone.sh << 'EOF'
#!/bin/bash
cd new-isms-frontend
export $(cat ../.env.codespaces-standalone | xargs)
npm run dev
EOF

# Make scripts executable
chmod +x scripts/start-backend-standalone.sh
chmod +x scripts/start-frontend-standalone.sh

# Create a combined startup script
cat > scripts/start-codespaces-standalone.sh << 'EOF'
#!/bin/bash

# Start backend in background
echo "Starting backend..."
bash scripts/start-backend-standalone.sh &
BACKEND_PID=$!

# Wait a moment for backend to start
sleep 5

# Start frontend in background
echo "Starting frontend..."
bash scripts/start-frontend-standalone.sh &
FRONTEND_PID=$!

echo ""
echo "🌐 ISMS Application Started!"
echo "   Frontend: http://localhost:3000"
echo "   Backend API: http://localhost:8000"
echo ""
echo "🔑 Login Credentials:"
echo "   Email: admin@test.com"
echo "   Password: admin123"
echo ""
echo "📊 Process IDs:"
echo "   Backend PID: $BACKEND_PID"
echo "   Frontend PID: $FRONTEND_PID"
echo ""
echo "To stop the application:"
echo "   kill $BACKEND_PID $FRONTEND_PID"
echo ""

# Wait for processes
wait
EOF

chmod +x scripts/start-codespaces-standalone.sh

print_success "Standalone setup completed!"
print_status "To start the application, run: bash scripts/start-codespaces-standalone.sh"
