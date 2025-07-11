#!/bin/bash

# ISMS Development Environment Restart Script
# This script restarts specific services or the entire environment

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Navigate to the project root
cd "$(dirname "$0")/.."

# Default to restarting all services
SERVICE=""
REBUILD=""

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --rebuild)
            REBUILD="--build"
            shift
            ;;
        -s|--service)
            SERVICE="$2"
            shift 2
            ;;
        frontend|backend|proxy)
            SERVICE="$1"
            shift
            ;;
        -h|--help)
            echo "Usage: $0 [OPTIONS] [SERVICE]"
            echo ""
            echo "Options:"
            echo "  --rebuild        Rebuild images before restarting"
            echo "  -s, --service    Restart specific service only"
            echo "  -h, --help       Show this help message"
            echo ""
            echo "Services:"
            echo "  frontend         Restart frontend service only"
            echo "  backend          Restart backend service only"
            echo "  proxy            Restart proxy service only"
            echo ""
            echo "Examples:"
            echo "  $0                    # Restart all services"
            echo "  $0 --rebuild          # Rebuild and restart all services"
            echo "  $0 frontend           # Restart frontend service only"
            echo "  $0 --rebuild backend  # Rebuild and restart backend service"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            echo "Use -h or --help for usage information"
            exit 1
            ;;
    esac
done

if [ -z "$SERVICE" ]; then
    print_status "Restarting all services..."
    if [ -n "$REBUILD" ]; then
        print_status "Rebuilding images..."
        docker compose -f docker-compose.dev.yml up --build -d
    else
        docker compose -f docker-compose.dev.yml restart
    fi
    print_success "All services restarted successfully!"
else
    print_status "Restarting $SERVICE service..."
    if [ -n "$REBUILD" ]; then
        print_status "Rebuilding $SERVICE image..."
        docker compose -f docker-compose.dev.yml up --build -d $SERVICE
    else
        docker compose -f docker-compose.dev.yml restart $SERVICE
    fi
    print_success "$SERVICE service restarted successfully!"
fi

# Show service status
print_status "Current service status:"
docker compose -f docker-compose.dev.yml ps
