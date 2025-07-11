#!/bin/bash

# ISMS Setup Validation Script
# This script validates the containerized setup without requiring Docker to be running

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
    echo -e "${GREEN}[✓]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[⚠]${NC} $1"
}

print_error() {
    echo -e "${RED}[✗]${NC} $1"
}

# Navigate to the project root
cd "$(dirname "$0")/.."

print_status "Validating ISMS Containerized Setup..."
echo ""

# Check project structure
print_status "Checking project structure..."

# Frontend files
if [ -f "new-isms-frontend/package.json" ]; then
    print_success "Frontend package.json exists"
else
    print_error "Frontend package.json missing"
fi

if [ -f "new-isms-frontend/Dockerfile" ]; then
    print_success "Frontend Dockerfile exists"
else
    print_error "Frontend Dockerfile missing"
fi

if [ -f "new-isms-frontend/vite.config.ts" ]; then
    print_success "Frontend Vite config exists"
else
    print_error "Frontend Vite config missing"
fi

# Backend files
if [ -f "isms-backend/requirements.txt" ]; then
    print_success "Backend requirements.txt exists"
else
    print_error "Backend requirements.txt missing"
fi

if [ -f "isms-backend/Dockerfile" ]; then
    print_success "Backend production Dockerfile exists"
else
    print_error "Backend production Dockerfile missing"
fi

if [ -f "isms-backend/Dockerfile.dev" ]; then
    print_success "Backend development Dockerfile exists"
else
    print_error "Backend development Dockerfile missing"
fi

# HAProxy files
if [ -f "haproxy/haproxy.cfg" ]; then
    print_success "HAProxy configuration exists"
else
    print_error "HAProxy configuration missing"
fi

if [ -f "haproxy/Dockerfile" ]; then
    print_success "HAProxy Dockerfile exists"
else
    print_error "HAProxy Dockerfile missing"
fi

# Docker Compose files
if [ -f "docker-compose.dev.yml" ]; then
    print_success "Development Docker Compose file exists"
else
    print_error "Development Docker Compose file missing"
fi

if [ -f "docker-compose.prod.yml" ]; then
    print_success "Production Docker Compose file exists"
else
    print_error "Production Docker Compose file missing"
fi

# Environment files
if [ -f ".env.development" ]; then
    print_success "Development environment file exists"
else
    print_error "Development environment file missing"
fi

if [ -f ".env.production.template" ]; then
    print_success "Production environment template exists"
else
    print_error "Production environment template missing"
fi

# Scripts
if [ -f "scripts/dev-start.sh" ] && [ -x "scripts/dev-start.sh" ]; then
    print_success "Development start script exists and is executable"
else
    print_error "Development start script missing or not executable"
fi

if [ -f "scripts/dev-stop.sh" ] && [ -x "scripts/dev-stop.sh" ]; then
    print_success "Development stop script exists and is executable"
else
    print_error "Development stop script missing or not executable"
fi

if [ -f "scripts/dev-logs.sh" ] && [ -x "scripts/dev-logs.sh" ]; then
    print_success "Development logs script exists and is executable"
else
    print_error "Development logs script missing or not executable"
fi

if [ -f "scripts/dev-restart.sh" ] && [ -x "scripts/dev-restart.sh" ]; then
    print_success "Development restart script exists and is executable"
else
    print_error "Development restart script missing or not executable"
fi

# Documentation
if [ -f "README.md" ]; then
    print_success "README documentation exists"
else
    print_error "README documentation missing"
fi

echo ""
print_status "Checking configuration files..."

# Check if Tauri dependencies have been removed from frontend
if grep -q "@tauri-apps" new-isms-frontend/package.json 2>/dev/null; then
    print_error "Tauri dependencies still present in frontend package.json"
else
    print_success "Tauri dependencies removed from frontend"
fi

# Check if src-tauri directory has been removed
if [ -d "new-isms-frontend/src-tauri" ]; then
    print_error "src-tauri directory still exists"
else
    print_success "src-tauri directory removed"
fi

# Check Vite configuration
if grep -q "TAURI_DEV_HOST" new-isms-frontend/vite.config.ts 2>/dev/null; then
    print_error "Tauri-specific configuration still present in vite.config.ts"
else
    print_success "Vite configuration updated for web deployment"
fi

echo ""
print_status "Validation Summary:"

# Count files
TOTAL_CHECKS=16
PASSED_CHECKS=0

# Re-run checks silently to count
[ -f "new-isms-frontend/package.json" ] && PASSED_CHECKS=$((PASSED_CHECKS + 1))
[ -f "new-isms-frontend/Dockerfile" ] && PASSED_CHECKS=$((PASSED_CHECKS + 1))
[ -f "new-isms-frontend/vite.config.ts" ] && PASSED_CHECKS=$((PASSED_CHECKS + 1))
[ -f "isms-backend/requirements.txt" ] && PASSED_CHECKS=$((PASSED_CHECKS + 1))
[ -f "isms-backend/Dockerfile" ] && PASSED_CHECKS=$((PASSED_CHECKS + 1))
[ -f "isms-backend/Dockerfile.dev" ] && PASSED_CHECKS=$((PASSED_CHECKS + 1))
[ -f "haproxy/haproxy.cfg" ] && PASSED_CHECKS=$((PASSED_CHECKS + 1))
[ -f "haproxy/Dockerfile" ] && PASSED_CHECKS=$((PASSED_CHECKS + 1))
[ -f "docker-compose.dev.yml" ] && PASSED_CHECKS=$((PASSED_CHECKS + 1))
[ -f "docker-compose.prod.yml" ] && PASSED_CHECKS=$((PASSED_CHECKS + 1))
[ -f ".env.development" ] && PASSED_CHECKS=$((PASSED_CHECKS + 1))
[ -f ".env.production.template" ] && PASSED_CHECKS=$((PASSED_CHECKS + 1))
[ -f "scripts/dev-start.sh" ] && [ -x "scripts/dev-start.sh" ] && PASSED_CHECKS=$((PASSED_CHECKS + 1))
[ -f "scripts/dev-stop.sh" ] && [ -x "scripts/dev-stop.sh" ] && PASSED_CHECKS=$((PASSED_CHECKS + 1))
[ -f "scripts/dev-logs.sh" ] && [ -x "scripts/dev-logs.sh" ] && PASSED_CHECKS=$((PASSED_CHECKS + 1))
[ -f "README.md" ] && PASSED_CHECKS=$((PASSED_CHECKS + 1))

if [ $PASSED_CHECKS -eq $TOTAL_CHECKS ]; then
    print_success "All validation checks passed! ($PASSED_CHECKS/$TOTAL_CHECKS)"
    echo ""
    print_status "Setup is ready for containerized development!"
    echo ""
    echo "Next steps:"
    echo "1. Ensure Docker is installed and running"
    echo "2. Run: ./scripts/dev-start.sh"
    echo "3. Access the application at http://localhost"
else
    print_warning "Some validation checks failed ($PASSED_CHECKS/$TOTAL_CHECKS passed)"
    echo ""
    print_status "Please fix the issues above before proceeding."
fi
