#!/bin/bash

# ISMS Development Environment Startup Script
# This script starts the complete development environment using Docker Compose

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

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    print_error "Docker is not running. Please start Docker and try again."
    exit 1
fi

# Check if Docker Compose is available
if ! docker compose version > /dev/null 2>&1; then
    print_error "Docker Compose is not available. Please install Docker Compose and try again."
    exit 1
fi

print_status "Starting ISMS Development Environment..."

# Navigate to the project root
cd "$(dirname "$0")/.."

# Load environment variables
if [ -f .env.development ]; then
    print_status "Loading development environment variables..."
    set -a  # automatically export all variables
    source .env.development
    set +a  # stop automatically exporting
else
    print_warning ".env.development file not found. Using default values."
fi

# Stop any existing containers
print_status "Stopping any existing containers..."
docker compose -f docker-compose.dev.yml down --remove-orphans

# Pull latest images (optional)
if [ "$1" = "--pull" ]; then
    print_status "Pulling latest base images..."
    docker compose -f docker-compose.dev.yml pull
fi

# Build and start services
print_status "Building and starting services..."
docker compose -f docker-compose.dev.yml up --build -d

# Wait for services to be healthy
print_status "Waiting for services to be ready..."
sleep 10

# Check service health
print_status "Checking service health..."

# Check backend health
if curl -f http://localhost:8000/health > /dev/null 2>&1; then
    print_success "Backend service is healthy"
else
    print_warning "Backend service may not be ready yet"
fi

# Check frontend health
if curl -f http://localhost:3000/health > /dev/null 2>&1; then
    print_success "Frontend service is healthy"
else
    print_warning "Frontend service may not be ready yet"
fi

# Check proxy health
if curl -f http://localhost/health > /dev/null 2>&1; then
    print_success "Proxy service is healthy"
else
    print_warning "Proxy service may not be ready yet"
fi

print_success "ISMS Development Environment started successfully!"
echo ""
echo "🌐 Application URLs:"
echo "   Main Application: http://localhost"
echo "   Frontend (direct): http://localhost:3000"
echo "   Backend API: http://localhost:8000"
echo "   HAProxy Stats: http://localhost:8404/stats (admin/admin123)"
echo ""
echo "📊 Useful Commands:"
echo "   View logs: ./scripts/dev-logs.sh"
echo "   Stop environment: ./scripts/dev-stop.sh"
echo "   Restart services: ./scripts/dev-restart.sh"
echo "   View status: docker compose -f docker-compose.dev.yml ps"
echo ""
print_status "Development environment is ready for use!"
