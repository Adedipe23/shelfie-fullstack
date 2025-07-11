#!/bin/bash

# ISMS GitHub Codespaces Simple Deployment Script
# This script starts the ISMS application using Docker outside of Docker

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

# Check if running in GitHub Codespaces
if [ -z "$CODESPACES" ]; then
    print_warning "Not running in GitHub Codespaces. Consider using dev-start.sh for local development."
fi

# Check if Docker is available
if ! command -v docker &> /dev/null; then
    print_error "Docker is not available. Please ensure Docker is installed."
    exit 1
fi

# Navigate to the project root
cd "$(dirname "$0")/.."

print_status "Starting ISMS Application for GitHub Codespaces..."
print_status "Using Docker outside of Docker approach..."

# Stop any existing containers
print_status "Stopping any existing containers..."
docker compose -f docker-compose.codespaces.yml down --remove-orphans 2>/dev/null || true

# Build and start services
print_status "Building and starting services..."
docker compose -f docker-compose.codespaces.yml up -d --build

# Wait for services to be ready
print_status "Waiting for services to be ready..."
sleep 15

# Check service health
print_status "Checking service health..."

# Check backend
for i in {1..30}; do
    if curl -f http://localhost:8000/health > /dev/null 2>&1; then
        print_success "Backend service is healthy"
        break
    else
        if [ $i -eq 30 ]; then
            print_warning "Backend service may not be ready yet"
        else
            sleep 2
        fi
    fi
done

# Check frontend
for i in {1..30}; do
    if curl -f http://localhost:3000 > /dev/null 2>&1; then
        print_success "Frontend service is healthy"
        break
    else
        if [ $i -eq 30 ]; then
            print_warning "Frontend service may not be ready yet"
        else
            sleep 2
        fi
    fi
done

print_success "ISMS Application started successfully for GitHub Codespaces!"

echo ""
echo "🌐 Application URLs (GitHub Codespaces):"
if [ -n "$CODESPACE_NAME" ]; then
    echo "   Frontend: https://$CODESPACE_NAME-3000.preview.app.github.dev"
    echo "   Backend API: https://$CODESPACE_NAME-8000.preview.app.github.dev"
else
    echo "   Frontend: http://localhost:3000"
    echo "   Backend API: http://localhost:8000"
fi
echo ""
echo "📊 Useful Commands:"
echo "   View logs: docker compose -f docker-compose.codespaces.yml logs -f"
echo "   Stop environment: docker compose -f docker-compose.codespaces.yml down"
echo "   Restart services: docker compose -f docker-compose.codespaces.yml restart"
echo "   View status: docker compose -f docker-compose.codespaces.yml ps"
echo ""
echo "🔧 Internal Container Communication:"
echo "   Frontend -> Backend: http://backend:8000"
echo "   This eliminates CORS issues in Codespaces!"
echo ""
echo "🔑 Login Credentials:"
echo "   Email: admin@test.com"
echo "   Password: admin123"
echo ""
print_status "Application is ready for use in GitHub Codespaces!"
