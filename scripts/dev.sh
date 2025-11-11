#!/bin/bash

# Palakat Monorepo Development Script
# This script helps run the full stack locally

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Helper functions
print_info() {
    echo -e "${BLUE}ℹ ${1}${NC}"
}

print_success() {
    echo -e "${GREEN}✓ ${1}${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ ${1}${NC}"
}

print_error() {
    echo -e "${RED}✗ ${1}${NC}"
}

print_section() {
    echo ""
    echo -e "${BLUE}=====================================${NC}"
    echo -e "${BLUE}${1}${NC}"
    echo -e "${BLUE}=====================================${NC}"
}

# Parse command line arguments
MODE="full"
FLUTTER_DEVICE=""

show_help() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Run the Palakat development stack"
    echo ""
    echo "Options:"
    echo "  --backend-only    Only start the backend"
    echo "  --app-only        Only start the Flutter app"
    echo "  --admin           Start the admin app instead of main app"
    echo "  --device DEVICE   Flutter device to use (e.g., chrome, macos)"
    echo "  -h, --help        Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0                         # Run full stack (backend + app)"
    echo "  $0 --backend-only          # Run only backend"
    echo "  $0 --app-only              # Run only Flutter app"
    echo "  $0 --device chrome         # Run app on Chrome"
    echo "  $0 --admin                 # Run admin app + backend"
}

while [[ $# -gt 0 ]]; do
    case $1 in
        --backend-only)
            MODE="backend"
            shift
            ;;
        --app-only)
            MODE="app"
            shift
            ;;
        --admin)
            MODE="admin"
            shift
            ;;
        --device)
            FLUTTER_DEVICE="$2"
            shift 2
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        *)
            print_error "Unknown option: $1"
            show_help
            exit 1
            ;;
    esac
done

# Trap to handle script termination
cleanup() {
    print_section "Shutting Down"
    if [ -n "$BACKEND_PID" ]; then
        print_info "Stopping backend (PID: $BACKEND_PID)..."
        kill $BACKEND_PID 2>/dev/null || true
    fi
    if [ -n "$FLUTTER_PID" ]; then
        print_info "Stopping Flutter app (PID: $FLUTTER_PID)..."
        kill $FLUTTER_PID 2>/dev/null || true
    fi
    print_success "Cleanup complete"
    exit 0
}

trap cleanup SIGINT SIGTERM

# Start backend
start_backend() {
    print_section "Starting Backend"

    if [ ! -d "apps/palakat_backend" ]; then
        print_error "Backend directory not found"
        exit 1
    fi

    if [ ! -f "apps/palakat_backend/.env" ]; then
        print_warning "Backend .env file not found"
        print_info "Please run ./scripts/setup.sh first"
        exit 1
    fi

    cd apps/palakat_backend
    print_info "Starting NestJS backend in development mode..."
    pnpm run start:dev &
    BACKEND_PID=$!
    cd ../..

    print_success "Backend started (PID: $BACKEND_PID)"

    # Wait a bit for backend to start
    print_info "Waiting for backend to initialize..."
    sleep 5

    # Check if backend is running
    if ps -p $BACKEND_PID > /dev/null; then
        print_success "Backend is running"
    else
        print_error "Backend failed to start"
        exit 1
    fi
}

# Start Flutter app
start_flutter_app() {
    print_section "Starting Flutter App"

    if [ ! -d "apps/palakat" ]; then
        print_error "App directory not found"
        exit 1
    fi

    if [ ! -f "apps/palakat/.env" ]; then
        print_warning "App .env file not found"
        print_info "Please run ./scripts/setup.sh first"
        exit 1
    fi

    cd apps/palakat

    # Build flutter run command
    FLUTTER_CMD="flutter run"
    if [ -n "$FLUTTER_DEVICE" ]; then
        FLUTTER_CMD="$FLUTTER_CMD -d $FLUTTER_DEVICE"
    fi

    # Check if FVM is available
    if command -v fvm &> /dev/null && [ -f ".fvmrc" ]; then
        FLUTTER_CMD="fvm $FLUTTER_CMD"
        print_info "Using FVM for Flutter"
    fi

    print_info "Starting Flutter app..."
    print_info "Command: $FLUTTER_CMD"

    $FLUTTER_CMD &
    FLUTTER_PID=$!
    cd ../..

    print_success "Flutter app started (PID: $FLUTTER_PID)"
}

# Start admin app
start_flutter_admin() {
    print_section "Starting Flutter Admin App"

    if [ ! -d "apps/palakat_admin" ]; then
        print_error "Admin app directory not found"
        exit 1
    fi

    if [ ! -f "apps/palakat_admin/.env" ]; then
        print_warning "Admin .env file not found"
        print_info "Please run ./scripts/setup.sh first"
        exit 1
    fi

    cd apps/palakat_admin

    # Build flutter run command
    FLUTTER_CMD="flutter run"
    if [ -n "$FLUTTER_DEVICE" ]; then
        FLUTTER_CMD="$FLUTTER_CMD -d $FLUTTER_DEVICE"
    fi

    # Check if FVM is available
    if command -v fvm &> /dev/null && [ -f ".fvmrc" ]; then
        FLUTTER_CMD="fvm $FLUTTER_CMD"
        print_info "Using FVM for Flutter"
    fi

    print_info "Starting Flutter admin app..."
    print_info "Command: $FLUTTER_CMD"

    $FLUTTER_CMD &
    FLUTTER_PID=$!
    cd ../..

    print_success "Flutter admin app started (PID: $FLUTTER_PID)"
}

# Main function
main() {
    echo ""
    echo -e "${GREEN}╔════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║   Palakat Development Environment     ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════╝${NC}"
    echo ""

    case $MODE in
        full)
            start_backend
            start_flutter_app
            print_section "Full Stack Running"
            print_success "Backend: http://localhost:3000"
            print_success "Flutter app: Running on selected device"
            ;;
        admin)
            start_backend
            start_flutter_admin
            print_section "Admin Stack Running"
            print_success "Backend: http://localhost:3000"
            print_success "Admin app: Running on selected device"
            ;;
        backend)
            start_backend
            print_section "Backend Running"
            print_success "Backend: http://localhost:3000"
            ;;
        app)
            start_flutter_app
            print_section "App Running"
            print_success "Flutter app: Running on selected device"
            ;;
    esac

    echo ""
    print_info "Press Ctrl+C to stop all services"
    echo ""

    # Wait for processes
    if [ -n "$BACKEND_PID" ]; then
        wait $BACKEND_PID
    fi
    if [ -n "$FLUTTER_PID" ]; then
        wait $FLUTTER_PID
    fi
}

# Run main function
main
