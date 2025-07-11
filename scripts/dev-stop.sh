#!/bin/bash

# ISMS Development Environment Stop Script
# This script stops the development environment and cleans up containers

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

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Navigate to the project root
cd "$(dirname "$0")/.."

print_status "Stopping ISMS Development Environment..."

# Stop and remove containers
docker compose -f docker-compose.dev.yml down

# Remove orphaned containers
print_status "Removing orphaned containers..."
docker compose -f docker-compose.dev.yml down --remove-orphans

# Optional: Remove volumes (if --clean flag is passed)
if [ "$1" = "--clean" ]; then
    print_warning "Removing development volumes (this will delete all data)..."
    docker compose -f docker-compose.dev.yml down --volumes
    print_warning "All development data has been removed!"
fi

# Optional: Remove images (if --images flag is passed)
if [ "$1" = "--images" ]; then
    print_status "Removing development images..."
    docker compose -f docker-compose.dev.yml down --rmi all
fi

print_success "ISMS Development Environment stopped successfully!"

# Show remaining containers (if any)
RUNNING_CONTAINERS=$(docker ps -q --filter "name=isms-")
if [ ! -z "$RUNNING_CONTAINERS" ]; then
    print_warning "Some ISMS containers are still running:"
    docker ps --filter "name=isms-"
else
    print_success "All ISMS containers have been stopped."
fi
