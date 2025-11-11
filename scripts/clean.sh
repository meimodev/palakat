#!/bin/bash

# Palakat Monorepo Clean Script
# This script cleans build artifacts and dependencies from all apps

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
CLEAN_FLUTTER=true
CLEAN_BACKEND=true
CLEAN_GENERATED=false
CLEAN_MELOS=true

show_help() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Clean build artifacts and dependencies from the monorepo"
    echo ""
    echo "Options:"
    echo "  --flutter-only    Clean only Flutter apps"
    echo "  --backend-only    Clean only backend"
    echo "  --generated       Also delete generated Dart files (*.g.dart, *.freezed.dart)"
    echo "  --no-melos        Don't clean Melos cache"
    echo "  -h, --help        Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0                         # Clean everything"
    echo "  $0 --flutter-only          # Clean only Flutter apps"
    echo "  $0 --generated             # Clean and remove generated files"
}

while [[ $# -gt 0 ]]; do
    case $1 in
        --flutter-only)
            CLEAN_BACKEND=false
            shift
            ;;
        --backend-only)
            CLEAN_FLUTTER=false
            shift
            ;;
        --generated)
            CLEAN_GENERATED=true
            shift
            ;;
        --no-melos)
            CLEAN_MELOS=false
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

# Clean Flutter apps
clean_flutter() {
    print_section "Cleaning Flutter Apps"

    if command -v melos &> /dev/null; then
        print_info "Running melos clean..."
        melos clean
        print_success "Flutter apps cleaned"
    else
        print_warning "Melos not found. Cleaning Flutter apps manually..."

        if [ -d "apps/palakat" ]; then
            print_info "Cleaning apps/palakat..."
            cd apps/palakat
            flutter clean
            rm -rf .dart_tool .flutter-plugins .flutter-plugins-dependencies build
            cd ../..
            print_success "Cleaned apps/palakat"
        fi

        if [ -d "apps/palakat_admin" ]; then
            print_info "Cleaning apps/palakat_admin..."
            cd apps/palakat_admin
            flutter clean
            rm -rf .dart_tool .flutter-plugins .flutter-plugins-dependencies build
            cd ../..
            print_success "Cleaned apps/palakat_admin"
        fi
    fi
}

# Clean backend
clean_backend() {
    print_section "Cleaning Backend"

    if [ -d "apps/palakat_backend" ]; then
        print_info "Cleaning apps/palakat_backend..."
        cd apps/palakat_backend

        # Remove node_modules
        if [ -d "node_modules" ]; then
            rm -rf node_modules
            print_success "Removed node_modules"
        fi

        # Remove dist
        if [ -d "dist" ]; then
            rm -rf dist
            print_success "Removed dist"
        fi

        # Remove coverage
        if [ -d "coverage" ]; then
            rm -rf coverage
            print_success "Removed coverage"
        fi

        cd ../..
        print_success "Backend cleaned"
    else
        print_warning "Backend directory not found"
    fi
}

# Clean generated files
clean_generated_files() {
    print_section "Cleaning Generated Files"

    print_warning "This will delete all generated Dart files"
    read -p "Are you sure? (y/n) " -n 1 -r
    echo

    if [[ $REPLY =~ ^[Yy]$ ]]; then
        print_info "Removing *.g.dart files..."
        find . -name "*.g.dart" -type f -delete

        print_info "Removing *.freezed.dart files..."
        find . -name "*.freezed.dart" -type f -delete

        print_info "Removing *.gen.dart files..."
        find . -name "*.gen.dart" -type f -delete

        print_success "Generated files removed"
        print_info "Run 'melos run build:runner' to regenerate"
    else
        print_info "Skipped removing generated files"
    fi
}

# Clean Melos cache
clean_melos_cache() {
    print_section "Cleaning Melos Cache"

    if [ -d ".melos_tool" ]; then
        rm -rf .melos_tool
        print_success "Removed .melos_tool directory"
    fi

    # Remove generated melos files
    if ls melos_*.yaml 1> /dev/null 2>&1; then
        rm -f melos_*.yaml
        print_success "Removed generated melos files"
    fi
}

# Main clean flow
main() {
    echo ""
    echo -e "${GREEN}╔════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║   Palakat Monorepo Clean Script       ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════╝${NC}"
    echo ""

    if [ "$CLEAN_FLUTTER" = true ]; then
        clean_flutter
    fi

    if [ "$CLEAN_BACKEND" = true ]; then
        clean_backend
    fi

    if [ "$CLEAN_MELOS" = true ]; then
        clean_melos_cache
    fi

    if [ "$CLEAN_GENERATED" = true ]; then
        clean_generated_files
    fi

    print_section "Clean Complete!"
    echo ""
    print_success "Monorepo has been cleaned!"
    echo ""
    print_info "To restore dependencies, run:"
    echo "  ./scripts/setup.sh"
    echo ""
}

# Run main function
main
