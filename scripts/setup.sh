#!/bin/bash

# Palakat Monorepo Setup Script
# This script sets up the development environment for all apps in the monorepo

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

# Check prerequisites
check_prerequisites() {
    print_section "Checking Prerequisites"

    local all_good=true

    # Check Flutter
    if command -v flutter &> /dev/null; then
        local flutter_version=$(flutter --version | head -n 1)
        print_success "Flutter installed: $flutter_version"
    else
        print_error "Flutter is not installed. Please install Flutter from https://flutter.dev"
        all_good=false
    fi

    # Check Dart
    if command -v dart &> /dev/null; then
        local dart_version=$(dart --version 2>&1 | head -n 1)
        print_success "Dart installed: $dart_version"
    else
        print_error "Dart is not installed. Please install Dart from https://dart.dev"
        all_good=false
    fi

    # Check Node.js
    if command -v node &> /dev/null; then
        local node_version=$(node --version)
        print_success "Node.js installed: $node_version"
    else
        print_error "Node.js is not installed. Please install Node.js from https://nodejs.org"
        all_good=false
    fi

    # Check pnpm
    if command -v pnpm &> /dev/null; then
        local pnpm_version=$(pnpm --version)
        print_success "pnpm installed: $pnpm_version"
    else
        print_warning "pnpm is not installed. Installing pnpm..."
        npm install -g pnpm
    fi

    # Check Melos
    if command -v melos &> /dev/null; then
        print_success "Melos installed"
    else
        print_warning "Melos is not installed. Installing Melos..."
        dart pub global activate melos
    fi

    # Check FVM (optional)
    if command -v fvm &> /dev/null; then
        print_success "FVM installed (optional)"
    else
        print_warning "FVM is not installed (optional, but recommended)"
    fi

    if [ "$all_good" = false ]; then
        print_error "Please install missing prerequisites and run this script again"
        exit 1
    fi

    print_success "All prerequisites are installed"
}

# Bootstrap Flutter apps
bootstrap_flutter() {
    print_section "Setting up Flutter Apps"

    print_info "Running melos bootstrap..."
    melos bootstrap

    print_success "Flutter apps bootstrapped"
}

# Install backend dependencies
setup_backend() {
    print_section "Setting up Backend"

    print_info "Installing backend dependencies (Prisma 7 + NestJS)..."
    cd apps/palakat_backend
    pnpm install

    print_info "Generating Prisma Client..."
    pnpm run prisma:generate

    cd ../..

    print_success "Backend dependencies installed and Prisma Client generated"
}

# Setup environment files
setup_env_files() {
    print_section "Checking Environment Files"

    # Palakat app
    if [ ! -f "apps/palakat/.env" ]; then
        print_warning "apps/palakat/.env not found"
        read -p "Create from .env.example? (y/n) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            cp apps/palakat/.env.example apps/palakat/.env
            print_success "Created apps/palakat/.env"
            print_warning "Please edit apps/palakat/.env with your configuration"
        fi
    else
        print_success "apps/palakat/.env exists"
    fi

    # Palakat admin
    if [ ! -f "apps/palakat_admin/.env" ]; then
        print_warning "apps/palakat_admin/.env not found"
        read -p "Create from .env.example? (y/n) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            cp apps/palakat_admin/.env.example apps/palakat_admin/.env
            print_success "Created apps/palakat_admin/.env"
            print_warning "Please edit apps/palakat_admin/.env with your configuration"
        fi
    else
        print_success "apps/palakat_admin/.env exists"
    fi

    # Backend
    if [ ! -f "apps/palakat_backend/.env" ]; then
        print_warning "apps/palakat_backend/.env not found"
        read -p "Create from .env.example? (y/n) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            cp apps/palakat_backend/.env.example apps/palakat_backend/.env
            print_success "Created apps/palakat_backend/.env"
            print_warning "Please edit apps/palakat_backend/.env with your configuration"
        fi
    else
        print_success "apps/palakat_backend/.env exists"
    fi
}

# Check Firebase configuration
check_firebase() {
    print_section "Checking Firebase Configuration"

    # Android
    if [ -f "apps/palakat/android/app/google-services.json" ]; then
        print_success "Android Firebase config exists"
    else
        print_warning "Missing: apps/palakat/android/app/google-services.json"
        print_info "Download from Firebase Console and place in apps/palakat/android/app/"
    fi

    # iOS
    if [ -f "apps/palakat/ios/Runner/GoogleService-Info.plist" ]; then
        print_success "iOS Firebase config exists"
    else
        print_warning "Missing: apps/palakat/ios/Runner/GoogleService-Info.plist"
        print_info "Download from Firebase Console and place in apps/palakat/ios/Runner/"
    fi
}

# Generate code
generate_code() {
    print_section "Generating Code"

    print_info "Running build_runner for all Flutter apps..."
    melos run build:runner

    print_success "Code generation complete"
}

# Main setup flow
main() {
    echo ""
    echo -e "${GREEN}╔════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║   Palakat Monorepo Setup Script       ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════╝${NC}"
    echo ""

    check_prerequisites
    bootstrap_flutter
    setup_backend
    setup_env_files
    check_firebase
    generate_code

    print_section "Setup Complete!"
    echo ""
    print_success "Monorepo setup is complete!"
    echo ""
    print_info "Next steps:"
    echo "  1. Configure .env files in each app directory"
    echo "  2. Add Firebase configuration files (if not already done)"
    echo "  3. Start the backend: cd apps/palakat_backend && pnpm run start:dev"
    echo "  4. Run the app: cd apps/palakat && flutter run"
    echo ""
    print_info "For more information, see README.md and CONTRIBUTING.md"
    echo ""
}

# Run main function
main
