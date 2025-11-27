#!/bin/bash

# Palakat Backend Local Development Script
# This script starts Docker, initializes the database, and runs the backend

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
START_BACKEND=true
SKIP_DOCKER=false
SKIP_SEED=false
INTERACTIVE_MODE=false

show_help() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Start the Palakat backend with Docker, database setup, and seeding"
    echo ""
    echo "Options:"
    echo "  --no-start        Don't start the backend after setup"
    echo "  --skip-docker     Skip Docker startup (if already running)"
    echo "  --skip-seed       Skip database seeding"
    echo "  --interactive     Use interactive mode to choose options"
    echo "  -h, --help        Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0                         # Interactive mode (asks questions)"
    echo "  $0 --no-start              # Setup only, don't start backend"
    echo "  $0 --skip-docker           # Skip Docker (if already running)"
    echo "  $0 --skip-seed             # Setup without seeding"
}

# Check if no arguments were provided - enable interactive mode
if [ $# -eq 0 ]; then
    INTERACTIVE_MODE=true
fi

while [[ $# -gt 0 ]]; do
    case $1 in
        --no-start)
            START_BACKEND=false
            shift
            ;;
        --skip-docker)
            SKIP_DOCKER=true
            shift
            ;;
        --skip-seed)
            SKIP_SEED=true
            shift
            ;;
        --interactive)
            INTERACTIVE_MODE=true
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

# Interactive mode - ask user for options
ask_interactive_options() {
    if [ "$INTERACTIVE_MODE" = false ]; then
        return
    fi

    echo ""
    echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║   Backend Setup Options                ║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
    echo ""

    # Ask about Docker
    read -p "$(echo -e ${YELLOW}❓ Start Docker services? [Y/n]:${NC} )" docker_choice
    docker_choice=${docker_choice:-Y}
    if [[ "$docker_choice" =~ ^[Nn]$ ]]; then
        SKIP_DOCKER=true
        print_info "Will skip Docker startup"
    else
        print_info "Will start Docker services"
    fi
    echo ""

    # Ask about seeding
    read -p "$(echo -e ${YELLOW}❓ Seed the database? [Y/n]:${NC} )" seed_choice
    seed_choice=${seed_choice:-Y}
    if [[ "$seed_choice" =~ ^[Nn]$ ]]; then
        SKIP_SEED=true
        print_info "Will skip database seeding"
    else
        print_info "Will seed the database"
    fi
    echo ""

    # Ask about starting backend
    read -p "$(echo -e ${YELLOW}❓ Start the backend server after setup? [Y/n]:${NC} )" start_choice
    start_choice=${start_choice:-Y}
    if [[ "$start_choice" =~ ^[Nn]$ ]]; then
        START_BACKEND=false
        print_info "Will not start the backend server"
    else
        print_info "Will start the backend server"
    fi
    echo ""
}

# Get the script directory and project root
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$( cd "$SCRIPT_DIR/.." && pwd )"
BACKEND_DIR="$PROJECT_ROOT/apps/palakat_backend"

# Trap to handle script termination
cleanup() {
    print_section "Shutting Down"
    if [ -n "$BACKEND_PID" ]; then
        print_info "Stopping backend (PID: $BACKEND_PID)..."
        kill $BACKEND_PID 2>/dev/null || true
    fi
    print_success "Cleanup complete"
    exit 0
}

trap cleanup SIGINT SIGTERM

# Check if backend directory exists
check_backend_directory() {
    if [ ! -d "$BACKEND_DIR" ]; then
        print_error "Backend directory not found at $BACKEND_DIR"
        exit 1
    fi
}

# Check if .env file exists
check_env_file() {
    print_section "Checking Environment Configuration"

    if [ ! -f "$BACKEND_DIR/.env" ]; then
        print_warning ".env file not found"

        if [ -f "$BACKEND_DIR/.env.example" ]; then
            print_info "Copying .env.example to .env..."
            cp "$BACKEND_DIR/.env.example" "$BACKEND_DIR/.env"
            print_success ".env file created"
            print_warning "Please review and update the .env file if needed"
        else
            print_error ".env.example not found"
            exit 1
        fi
    else
        print_success ".env file exists"
    fi
}

# Check if Docker is installed
check_docker() {
    if [ "$SKIP_DOCKER" = true ]; then
        print_info "Skipping Docker check"
        return
    fi

    print_section "Checking Docker"

    if ! command -v docker &> /dev/null; then
        print_error "Docker is not installed"
        print_info "Please install Docker from https://www.docker.com/get-started"
        exit 1
    fi

    # Check if Docker daemon is responding (with background process timeout for macOS)
    print_info "Checking if Docker daemon is responding..."
    
    # Run docker info in background and wait with timeout
    docker info &> /dev/null &
    DOCKER_PID=$!
    
    # Wait up to 5 seconds
    WAIT_COUNT=0
    while kill -0 $DOCKER_PID 2>/dev/null; do
        if [ $WAIT_COUNT -ge 5 ]; then
            kill $DOCKER_PID 2>/dev/null || true
            print_error "Docker is not responding (timed out)"
            print_info "Please start Docker Desktop and try again"
            print_info "Or run with --skip-docker if database is already available"
            exit 1
        fi
        sleep 1
        WAIT_COUNT=$((WAIT_COUNT + 1))
    done
    
    # Check if docker info succeeded
    wait $DOCKER_PID
    if [ $? -ne 0 ]; then
        print_error "Docker is not running"
        print_info "Please start Docker Desktop and try again"
        print_info "Or run with --skip-docker if database is already available"
        exit 1
    fi

    print_success "Docker is installed and running"
}

# Start Docker services
start_docker() {
    if [ "$SKIP_DOCKER" = true ]; then
        print_section "Skipping Docker Startup"
        print_info "Assuming Docker services are already running"
        return
    fi

    print_section "Starting Docker Services"

    cd "$BACKEND_DIR"

    # Check if containers are already running
    if docker-compose ps | grep -q "Up"; then
        print_info "Docker containers are already running"
        print_info "Stopping existing containers..."
        docker-compose down
    fi

    print_info "Starting Docker containers..."
    docker-compose up -d

    print_success "Docker containers started"
}

# Wait for PostgreSQL to be ready
wait_for_postgres() {
    if [ "$SKIP_DOCKER" = true ]; then
        print_section "Skipping PostgreSQL Wait"
        print_info "Assuming PostgreSQL is already available"
        return
    fi

    print_section "Waiting for PostgreSQL"

    cd "$BACKEND_DIR"

    # Source the .env file to get database credentials
    if [ -f "$BACKEND_DIR/.env" ]; then
        export $(cat "$BACKEND_DIR/.env" | grep -v '^#' | xargs)
    fi

    POSTGRES_HOST=${POSTGRES_HOST:-localhost}
    POSTGRES_PORT=${POSTGRES_PORT:-5432}
    POSTGRES_USER=${POSTGRES_USER:-root}
    POSTGRES_DB=${POSTGRES_DB:-database}

    print_info "Checking PostgreSQL connection at $POSTGRES_HOST:$POSTGRES_PORT..."

    MAX_RETRIES=30
    RETRY_COUNT=0

    # Get the container ID using docker-compose
    CONTAINER_ID=$(docker-compose ps -q postgres 2>/dev/null)

    if [ -z "$CONTAINER_ID" ]; then
        print_warning "Could not find postgres container via docker-compose"
        print_info "Trying to connect directly via pg_isready..."
        
        # Try direct connection if pg_isready is available locally
        if command -v pg_isready &> /dev/null; then
            while [ $RETRY_COUNT -lt $MAX_RETRIES ]; do
                if pg_isready -h "$POSTGRES_HOST" -p "$POSTGRES_PORT" -U "$POSTGRES_USER" &> /dev/null; then
                    print_success "PostgreSQL is ready"
                    return 0
                fi
                RETRY_COUNT=$((RETRY_COUNT + 1))
                print_info "Waiting for PostgreSQL... (attempt $RETRY_COUNT/$MAX_RETRIES)"
                sleep 1
            done
        else
            # Fallback: just wait a bit and assume it's ready
            print_info "pg_isready not available locally, waiting 5 seconds..."
            sleep 5
            print_success "Assuming PostgreSQL is ready"
            return 0
        fi
    else
        while [ $RETRY_COUNT -lt $MAX_RETRIES ]; do
            if docker exec "$CONTAINER_ID" pg_isready -h localhost -U "$POSTGRES_USER" &> /dev/null; then
                print_success "PostgreSQL is ready"
                return 0
            fi

            RETRY_COUNT=$((RETRY_COUNT + 1))
            print_info "Waiting for PostgreSQL... (attempt $RETRY_COUNT/$MAX_RETRIES)"
            sleep 1
        done
    fi

    print_error "PostgreSQL failed to become ready after $MAX_RETRIES attempts"
    exit 1
}

# Setup database
setup_database() {
    print_section "Setting Up Database"

    cd "$BACKEND_DIR"

    # Check if pnpm is installed
    if ! command -v pnpm &> /dev/null; then
        print_error "pnpm is not installed"
        print_info "Please install pnpm: npm install -g pnpm"
        exit 1
    fi

    # Install dependencies if node_modules doesn't exist
    if [ ! -d "node_modules" ]; then
        print_info "Installing dependencies (including Prisma 7)..."
        pnpm install
    fi

    # Generate Prisma Client
    print_info "Generating Prisma Client..."
    pnpm run prisma:generate

    # Check if migrations exist
    if [ -d "prisma/migrations" ] && [ "$(ls -A prisma/migrations)" ]; then
        print_info "Running database migrations..."
        pnpm run db:migrate
    else
        print_info "No migrations found. Pushing database schema..."
        pnpm run db:push
    fi

    print_success "Database setup completed successfully"
}

# Seed database
seed_database() {
    if [ "$SKIP_SEED" = true ]; then
        print_section "Skipping Database Seeding"
        return
    fi

    print_section "Seeding Database"

    cd "$BACKEND_DIR"

    print_info "Running database seed..."
    pnpm run db:seed

    print_success "Database seeded successfully"
}

# Start backend server
start_backend_server() {
    if [ "$START_BACKEND" = false ]; then
        print_section "Backend Setup Complete"
        print_info "Backend server not started (--no-start flag)"
        print_info "To start the backend manually, run:"
        print_info "  cd apps/palakat_backend && pnpm run start:dev"
        return
    fi

    print_section "Starting Backend Server"

    cd "$BACKEND_DIR"

    print_info "Starting NestJS backend in development mode..."
    print_info "Backend will be available at http://localhost:3000"
    echo ""

    pnpm run start:dev &
    BACKEND_PID=$!

    print_success "Backend started (PID: $BACKEND_PID)"
    print_info "Press Ctrl+C to stop the backend"
    echo ""

    # Wait for the backend process
    wait $BACKEND_PID
}

# Main function
main() {
    echo ""
    echo -e "${GREEN}╔════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║   Palakat Backend Local Setup         ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════╝${NC}"
    echo ""

    ask_interactive_options
    check_backend_directory
    check_env_file
    check_docker
    start_docker
    wait_for_postgres
    setup_database
    seed_database
    start_backend_server
}

# Run main function
main
