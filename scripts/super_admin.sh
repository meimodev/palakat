#!/bin/bash

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$( cd "$SCRIPT_DIR/.." && pwd )"
SUPER_ADMIN_DIR="$PROJECT_ROOT/apps/palakat_super_admin"
ENV_UTILS="$SCRIPT_DIR/env_utils.sh"

# shellcheck disable=SC1090
source "$ENV_UTILS"

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
SELECTED_ENV="local"

show_help() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Start the Palakat Super Admin app"
    echo ""
    echo "Options:"
    echo "  --env ENVIRONMENT  Environment to use (local, staging, production)"
    echo "  --device DEVICE    Flutter device to use (e.g., chrome, macos, windows, linux)"
    echo "  --release          Run in release mode"
    echo "  -h, --help         Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0                                   # Run with local env"
    echo "  $0 --env staging --device chrome"
    echo "  $0 --env production --release"
}

while [[ $# -gt 0 ]]; do
    case $1 in
        --env)
            if [[ -z "$2" ]]; then
                print_error "Missing value for --env"
                show_help
                exit 1
            fi

            if ! is_supported_env_name "$2"; then
                print_error "Unsupported environment: $2"
                print_info "Supported environments: $(supported_env_names_text)"
                exit 1
            fi

            SELECTED_ENV="$(normalize_env_name "$2")"
            shift 2
            ;;
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

cleanup() {
    print_section "Shutting Down"
    if [ -n "$FLUTTER_PID" ]; then
        print_info "Stopping Flutter super admin app (PID: $FLUTTER_PID)..."
        kill "$FLUTTER_PID" 2>/dev/null || true
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

    local active_env_file
    active_env_file="$(create_temp_env_file "palakat_super_admin_${SELECTED_ENV}")"

    if ! extract_env_section_to_file "$SUPER_ADMIN_DIR/.env" "$SELECTED_ENV" "$active_env_file"; then
        local status=$?
        rm -f "$active_env_file"

        if [ $status -eq 2 ]; then
            print_error "Environment '$SELECTED_ENV' is not defined in $SUPER_ADMIN_DIR/.env"
        else
            print_error "Failed to read $SUPER_ADMIN_DIR/.env"
        fi
        exit 1
    fi

    local missing_keys
    missing_keys="$(missing_env_keys_text "$active_env_file" API_BASE_URL API_BASE_VERSION APP_CLIENT_USERNAME APP_CLIENT_PASSWORD)"
    rm -f "$active_env_file"

    if [ -n "$missing_keys" ]; then
        print_error "Selected environment '$SELECTED_ENV' is missing required variables: $missing_keys"
        exit 1
    fi

    print_success "Environment '$SELECTED_ENV' is configured"
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

    FLUTTER_CMD=(flutter run --dart-define="PALAKAT_ENV=$SELECTED_ENV")

    if [ -n "$FLUTTER_DEVICE" ]; then
        FLUTTER_CMD+=(-d "$FLUTTER_DEVICE")
    fi

    if [ "$RELEASE_MODE" = true ]; then
        FLUTTER_CMD+=(--release)
    fi

    if command -v fvm &> /dev/null && [ -f ".fvmrc" ]; then
        FLUTTER_CMD=(fvm "${FLUTTER_CMD[@]}")
        print_info "Using FVM for Flutter"
    fi

    print_info "Selected environment: $SELECTED_ENV"
    print_info "Starting Flutter super admin app..."
    print_info "Command: ${FLUTTER_CMD[*]}"
    echo ""

    print_success "Flutter super admin app started"
    print_info "Press Ctrl+C to stop the app"
    echo ""

    "${FLUTTER_CMD[@]}"
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
