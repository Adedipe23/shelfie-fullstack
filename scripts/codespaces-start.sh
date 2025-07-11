#!/bin/bash

# ISMS GitHub Codespaces Deployment Script
# This script starts the ISMS application optimized for GitHub Codespaces

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

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    print_error "Docker is not running. Please start Docker and try again."
    exit 1
fi

# Navigate to the project root
cd "$(dirname "$0")/.."

print_status "Starting ISMS Application for GitHub Codespaces..."
print_status "Using internal container networking to avoid CORS issues..."

# Stop any existing containers
print_status "Stopping any existing containers..."
docker compose -f docker-compose.codespaces.yml down --remove-orphans 2>/dev/null || true

# Build and start services without proxy (pure internal networking)
print_status "Building and starting services with internal networking..."
docker compose -f docker-compose.codespaces.yml up -d --build

# Wait for services to be ready
print_status "Waiting for services to be ready..."
sleep 10

# Check service health
print_status "Checking service health..."

# Check backend
if curl -f http://localhost:8000/health > /dev/null 2>&1; then
    print_success "Backend service is healthy"
else
    print_warning "Backend service may not be ready yet"
fi

# Check frontend
if curl -f http://localhost:3000 > /dev/null 2>&1; then
    print_success "Frontend service is healthy"
else
    print_warning "Frontend service may not be ready yet"
fi

print_success "ISMS Application started successfully for GitHub Codespaces!"

echo ""
echo "🌐 Application URLs (GitHub Codespaces):"
echo "   Frontend: https://$CODESPACE_NAME-3000.preview.app.github.dev"
echo "   Backend API: https://$CODESPACE_NAME-8000.preview.app.github.dev"
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
print_status "Application is ready for use in GitHub Codespaces!"
