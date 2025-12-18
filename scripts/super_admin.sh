#!/bin/bash

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

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

FLUTTER_DEVICE=""
RELEASE_MODE=false

show_help() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Start the Palakat Super Admin app"
    echo ""
    echo "Options:"
    echo "  --device DEVICE   Flutter device to use (e.g., chrome, macos, windows, linux)"
    echo "  --release         Run in release mode"
    echo "  -h, --help        Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0                         # Run on default device"
    echo "  $0 --device chrome         # Run on Chrome"
    echo "  $0 --device macos          # Run on macOS"
    echo "  $0 --release               # Run in release mode"
}

while [[ $# -gt 0 ]]; do
    case $1 in
        --device)
            FLUTTER_DEVICE="$2"
            shift 2
            ;;
        --release)
            RELEASE_MODE=true
            shift
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

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$( cd "$SCRIPT_DIR/.." && pwd )"
SUPER_ADMIN_DIR="$PROJECT_ROOT/apps/palakat_super_admin"

cleanup() {
    print_section "Shutting Down"
    if [ -n "$FLUTTER_PID" ]; then
        print_info "Stopping Flutter super admin app (PID: $FLUTTER_PID)..."
        kill $FLUTTER_PID 2>/dev/null || true
    fi
    print_success "Cleanup complete"
    exit 0
}

trap cleanup SIGINT SIGTERM

check_super_admin_directory() {
    if [ ! -d "$SUPER_ADMIN_DIR" ]; then
        print_error "Super admin app directory not found at $SUPER_ADMIN_DIR"
        exit 1
    fi
}

check_env_file() {
    print_section "Checking Environment Configuration"

    if [ ! -f "$SUPER_ADMIN_DIR/.env" ]; then
        print_warning ".env file not found"

        if [ -f "$SUPER_ADMIN_DIR/.env.example" ]; then
            print_info "Copying .env.example to .env..."
            cp "$SUPER_ADMIN_DIR/.env.example" "$SUPER_ADMIN_DIR/.env"
            print_success ".env file created"
            print_warning "Please review and update apps/palakat_super_admin/.env"
        else
            print_error ".env.example not found"
            exit 1
        fi
    else
        print_success ".env file exists"
    fi
}

check_flutter() {
    if ! command -v flutter &> /dev/null; then
        print_error "Flutter is not installed"
        print_info "Please install Flutter from https://flutter.dev"
        exit 1
    fi

    print_success "Flutter is installed"
}

start_super_admin_app() {
    print_section "Starting Palakat Super Admin App"

    cd "$SUPER_ADMIN_DIR"

    FLUTTER_CMD="flutter run"

    if [ -n "$FLUTTER_DEVICE" ]; then
        FLUTTER_CMD="$FLUTTER_CMD -d $FLUTTER_DEVICE"
    fi

    if [ "$RELEASE_MODE" = true ]; then
        FLUTTER_CMD="$FLUTTER_CMD --release"
    fi

    if command -v fvm &> /dev/null && [ -f ".fvmrc" ]; then
        FLUTTER_CMD="fvm $FLUTTER_CMD"
        print_info "Using FVM for Flutter"
    fi

    print_info "Starting Flutter super admin app..."
    print_info "Command: $FLUTTER_CMD"
    echo ""

    $FLUTTER_CMD &
    FLUTTER_PID=$!

    print_success "Flutter super admin app started (PID: $FLUTTER_PID)"
    print_info "Press Ctrl+C to stop the app"
    echo ""

    wait $FLUTTER_PID
}

main() {
    echo ""
    echo -e "${GREEN}╔════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║   Palakat Super Admin Development      ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════╝${NC}"
    echo ""

    check_super_admin_directory
    check_env_file
    check_flutter
    start_super_admin_app
}

main
