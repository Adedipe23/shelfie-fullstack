#!/bin/bash

# ISMS Development Environment Logs Script
# This script shows logs from the development environment services

set -e

# Colors for output
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

# Navigate to the project root
cd "$(dirname "$0")/.."

# Default to showing all logs
SERVICE=""
FOLLOW=""

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -f|--follow)
            FOLLOW="-f"
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
            echo "  -f, --follow     Follow log output"
            echo "  -s, --service    Specify service name"
            echo "  -h, --help       Show this help message"
            echo ""
            echo "Services:"
            echo "  frontend         Show frontend logs only"
            echo "  backend          Show backend logs only"
            echo "  proxy            Show proxy logs only"
            echo ""
            echo "Examples:"
            echo "  $0                    # Show all logs"
            echo "  $0 -f                # Follow all logs"
            echo "  $0 frontend           # Show frontend logs only"
            echo "  $0 -f backend         # Follow backend logs only"
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
    print_status "Showing logs for all services..."
    docker compose -f docker-compose.dev.yml logs $FOLLOW
else
    print_status "Showing logs for $SERVICE service..."
    docker compose -f docker-compose.dev.yml logs $FOLLOW $SERVICE
fi
