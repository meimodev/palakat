#!/bin/bash

# Palakat Prisma Management Script
# This script provides convenient commands for Prisma 7 operations

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

# Get the script directory and project root
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$( cd "$SCRIPT_DIR/.." && pwd )"
BACKEND_DIR="$PROJECT_ROOT/apps/palakat_backend"

# Show help
show_help() {
    echo "Usage: $0 COMMAND [OPTIONS]"
    echo ""
    echo "Prisma 7 management commands for Palakat backend"
    echo ""
    echo "Commands:"
    echo "  generate          Generate Prisma Client"
    echo "  migrate           Create and apply a new migration"
    echo "  migrate-dev       Run migrations in development"
    echo "  migrate-deploy    Deploy migrations to production"
    echo "  push              Push schema changes without migration"
    echo "  studio            Open Prisma Studio"
    echo "  validate          Validate the Prisma schema"
    echo "  format            Format the Prisma schema"
    echo "  seed              Seed the database"
    echo "  reset             Reset the database (WARNING: deletes all data)"
    echo "  status            Show migration status"
    echo "  test              Test Prisma connection"
    echo ""
    echo "Options:"
    echo "  -h, --help        Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 generate                # Generate Prisma Client"
    echo "  $0 migrate                 # Create new migration"
    echo "  $0 studio                  # Open Prisma Studio"
    echo "  $0 validate                # Validate schema"
}

# Check if backend directory exists
check_backend() {
    if [ ! -d "$BACKEND_DIR" ]; then
        print_error "Backend directory not found at $BACKEND_DIR"
        exit 1
    fi
    cd "$BACKEND_DIR"
}

# Generate Prisma Client
prisma_generate() {
    print_section "Generating Prisma Client"
    print_info "Using Prisma 7 with PostgreSQL adapter..."
    pnpm run prisma:generate
    print_success "Prisma Client generated successfully"
}

# Create and apply migration
prisma_migrate() {
    print_section "Creating Migration"
    print_warning "This will create a new migration and apply it to the database"
    read -p "Migration name: " migration_name
    
    if [ -z "$migration_name" ]; then
        print_error "Migration name is required"
        exit 1
    fi
    
    print_info "Creating migration: $migration_name"
    pnpm prisma migrate dev --name "$migration_name" --schema=./prisma/schema.prisma
    print_success "Migration created and applied"
}

# Run migrations in development
prisma_migrate_dev() {
    print_section "Running Development Migrations"
    pnpm run db:migrate
    print_success "Migrations applied"
}

# Deploy migrations
prisma_migrate_deploy() {
    print_section "Deploying Migrations"
    print_warning "This will deploy pending migrations to the database"
    pnpm run db:deploy
    print_success "Migrations deployed"
}

# Push schema
prisma_push() {
    print_section "Pushing Schema"
    print_warning "This will push schema changes without creating a migration"
    print_warning "This is useful for prototyping but not recommended for production"
    read -p "Continue? (y/n) " -n 1 -r
    echo
    
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_info "Cancelled"
        exit 0
    fi
    
    pnpm run db:push
    print_success "Schema pushed"
}

# Open Prisma Studio
prisma_studio() {
    print_section "Opening Prisma Studio"
    print_info "Prisma Studio will open in your browser..."
    print_info "Press Ctrl+C to stop Prisma Studio"
    pnpm run prisma:studio
}

# Validate schema
prisma_validate() {
    print_section "Validating Prisma Schema"
    pnpm prisma validate --schema=./prisma/schema.prisma
    print_success "Schema is valid"
}

# Format schema
prisma_format() {
    print_section "Formatting Prisma Schema"
    pnpm prisma format --schema=./prisma/schema.prisma
    print_success "Schema formatted"
}

# Seed database
prisma_seed() {
    print_section "Seeding Database"
    pnpm run db:seed
    print_success "Database seeded"
}

# Reset database
prisma_reset() {
    print_section "Resetting Database"
    print_error "WARNING: This will delete all data in the database!"
    read -p "Are you absolutely sure? Type 'yes' to confirm: " confirm
    
    if [ "$confirm" != "yes" ]; then
        print_info "Cancelled"
        exit 0
    fi
    
    print_info "Resetting database..."
    pnpm prisma migrate reset --schema=./prisma/schema.prisma --force
    print_success "Database reset complete"
}

# Show migration status
prisma_status() {
    print_section "Migration Status"
    pnpm prisma migrate status --schema=./prisma/schema.prisma
}

# Test connection
prisma_test() {
    print_section "Testing Prisma Connection"
    
    if [ ! -f "test-prisma-connection.ts" ]; then
        print_error "Test file not found"
        print_info "Please ensure test-prisma-connection.ts exists in the backend directory"
        exit 1
    fi
    
    print_info "Running connection test..."
    pnpm run test:prisma
}

# Main function
main() {
    if [ $# -eq 0 ]; then
        show_help
        exit 0
    fi

    COMMAND=$1
    shift

    # Parse options
    while [[ $# -gt 0 ]]; do
        case $1 in
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

    echo ""
    echo -e "${GREEN}╔════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║   Palakat Prisma 7 Management         ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════╝${NC}"
    echo ""

    check_backend

    case $COMMAND in
        generate)
            prisma_generate
            ;;
        migrate)
            prisma_migrate
            ;;
        migrate-dev)
            prisma_migrate_dev
            ;;
        migrate-deploy)
            prisma_migrate_deploy
            ;;
        push)
            prisma_push
            ;;
        studio)
            prisma_studio
            ;;
        validate)
            prisma_validate
            ;;
        format)
            prisma_format
            ;;
        seed)
            prisma_seed
            ;;
        reset)
            prisma_reset
            ;;
        status)
            prisma_status
            ;;
        test)
            prisma_test
            ;;
        *)
            print_error "Unknown command: $COMMAND"
            show_help
            exit 1
            ;;
    esac

    echo ""
}

# Run main function
main "$@"
