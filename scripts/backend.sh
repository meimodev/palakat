#!/bin/bash

# Palakat Backend Development Script
# This script starts Docker, initializes the local database, and runs the backend

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$( cd "$SCRIPT_DIR/.." && pwd )"
BACKEND_DIR="$PROJECT_ROOT/apps/palakat_backend"
ENV_UTILS="$SCRIPT_DIR/env_utils.sh"

# shellcheck disable=SC1090
source "$ENV_UTILS"

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

normalize_choice() {
    echo "${1}" | tr '[:upper:]' '[:lower:]' | tr -d '[:space:]'
}

# Parse command line arguments
SKIP_DOCKER=false
SKIP_SEED=false
INTERACTIVE_MODE=false
SELECTED_ENV="local"
ENV_WAS_EXPLICIT=false
ACTIVE_ENV_FILE=""
BACKEND_PID=""
COMPOSE_CMD=()

show_help() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Start the Palakat backend with environment-aware startup"
    echo ""
    echo "Options:"
    echo "  --env ENVIRONMENT  Environment to use (local, staging, production)"
    echo "  --skip-docker      Skip Docker startup (if already running)"
    echo "  --skip-seed        Skip database seeding"
    echo "  --interactive      Use interactive mode to choose options"
    echo "  -h, --help         Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0                          # Interactive mode (asks questions)"
    echo "  $0 --env local             # Local env with Docker + DB bootstrap"
    echo "  $0 --env staging           # Staging env without local DB bootstrap"
    echo "  $0 --env production        # Production env without local DB bootstrap"
    echo "  $0 --env local --skip-seed"
}

# Check if no arguments were provided - enable interactive mode
if [ $# -eq 0 ]; then
    INTERACTIVE_MODE=true
fi

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
            ENV_WAS_EXPLICIT=true
            shift 2
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

cleanup_temp_env_file() {
    if [ -n "$ACTIVE_ENV_FILE" ] && [ -f "$ACTIVE_ENV_FILE" ]; then
        rm -f "$ACTIVE_ENV_FILE"
    fi
}

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

    if [ "$ENV_WAS_EXPLICIT" = false ]; then
        read -p "$(echo -e ${YELLOW}❓ Environment [local/staging/production] (default: local):${NC} )" env_choice
        env_choice="${env_choice:-local}"
        env_choice="$(normalize_env_name "$env_choice")"

        if ! is_supported_env_name "$env_choice"; then
            print_error "Invalid environment: $env_choice"
            print_info "Supported environments: $(supported_env_names_text)"
            exit 1
        fi

        SELECTED_ENV="$env_choice"
    fi

    print_info "Selected environment: $SELECTED_ENV"
    echo ""

    if [ "$SELECTED_ENV" != "local" ]; then
        print_info "Non-local environment selected"
        print_info "Docker startup, database bootstrap, and seeding will be skipped"
        echo ""
        return
    fi

    read -p "$(echo -e ${YELLOW}❓ Start Docker services? [Y/n]:${NC} )" docker_choice
    docker_choice=$(normalize_choice "${docker_choice:-Y}")
    if [[ "$docker_choice" == "n" || "$docker_choice" == "no" ]]; then
        SKIP_DOCKER=true
        print_info "Will skip Docker startup"
    else
        print_info "Will start Docker services"
    fi
    echo ""

    read -p "$(echo -e ${YELLOW}❓ Seed the database? [Y/n]:${NC} )" seed_choice
    seed_choice=$(normalize_choice "${seed_choice:-Y}")
    if [[ "$seed_choice" == "n" || "$seed_choice" == "no" ]]; then
        SKIP_SEED=true
        print_info "Will skip database seeding"
    else
        print_info "Will seed the database"
    fi
    echo ""

    print_info "Will start the backend server"
    echo ""
}

apply_environment_defaults() {
    if [ "$SELECTED_ENV" = "local" ]; then
        return
    fi

    if [ "$SKIP_DOCKER" = false ]; then
        print_info "Skipping Docker startup for '$SELECTED_ENV' environment"
    fi
    SKIP_DOCKER=true

    if [ "$SKIP_SEED" = false ]; then
        print_info "Skipping database seeding for '$SELECTED_ENV' environment"
    fi
    SKIP_SEED=true
}

# Trap to handle script termination
cleanup() {
    print_section "Shutting Down"
    if [ -n "$BACKEND_PID" ]; then
        print_info "Stopping backend (PID: $BACKEND_PID)..."
        kill "$BACKEND_PID" 2>/dev/null || true
    fi
    cleanup_temp_env_file
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

check_env_file() {
    print_section "Checking Environment Configuration"

    if [ ! -f "$BACKEND_DIR/.env" ]; then
        print_warning ".env file not found"

        if [ -f "$BACKEND_DIR/.env.example" ]; then
            print_info "Copying .env.example to .env..."
            cp "$BACKEND_DIR/.env.example" "$BACKEND_DIR/.env"
            print_success ".env file created"
            print_warning "Please review and update apps/palakat_backend/.env"
        else
            print_error ".env.example not found"
            exit 1
        fi
    else
        print_success ".env file exists"
    fi
}

prepare_active_environment() {
    print_section "Preparing Environment Variables"

    ACTIVE_ENV_FILE="$(create_temp_env_file "palakat_backend_${SELECTED_ENV}")"

    if ! extract_env_section_to_file "$BACKEND_DIR/.env" "$SELECTED_ENV" "$ACTIVE_ENV_FILE"; then
        local status=$?
        cleanup_temp_env_file

        if [ $status -eq 2 ]; then
            print_error "Environment '$SELECTED_ENV' is not defined in $BACKEND_DIR/.env"
        else
            print_error "Failed to read $BACKEND_DIR/.env"
        fi
        exit 1
    fi

    local required_keys=(PORT PUBLIC_BASE_URL DATABASE_URL APP_CLIENT_USERNAME APP_CLIENT_PASSWORD JWT_SECRET)
    if [ "$SELECTED_ENV" = "local" ]; then
        required_keys+=(POSTGRES_DB POSTGRES_USER POSTGRES_PASSWORD POSTGRES_PORT)
    fi

    local missing_keys
    missing_keys="$(missing_env_keys_text "$ACTIVE_ENV_FILE" "${required_keys[@]}")"
    if [ -n "$missing_keys" ]; then
        print_error "Selected environment '$SELECTED_ENV' is missing required variables: $missing_keys"
        cleanup_temp_env_file
        exit 1
    fi

    export PALAKAT_ENV="$SELECTED_ENV"
    export DOTENV_CONFIG_PATH="$ACTIVE_ENV_FILE"

    set -a
    # shellcheck disable=SC1090
    source "$ACTIVE_ENV_FILE"
    set +a

    print_success "Loaded '$SELECTED_ENV' environment"
}

detect_compose_command() {
    if [ ${#COMPOSE_CMD[@]} -gt 0 ]; then
        return
    fi

    if docker compose version &> /dev/null; then
        COMPOSE_CMD=(docker compose)
        return
    fi

    if command -v docker-compose &> /dev/null; then
        COMPOSE_CMD=(docker-compose)
        return
    fi

    print_error "Docker Compose is not available"
    exit 1
}

run_compose() {
    detect_compose_command
    "${COMPOSE_CMD[@]}" --env-file "$ACTIVE_ENV_FILE" -f "$BACKEND_DIR/docker-compose.yaml" "$@"
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

    detect_compose_command

    print_info "Checking if Docker daemon is responding..."

    docker info &> /dev/null &
    DOCKER_PID=$!

    WAIT_COUNT=0
    while kill -0 $DOCKER_PID 2>/dev/null; do
        if [ $WAIT_COUNT -ge 5 ]; then
            kill $DOCKER_PID 2>/dev/null || true
            print_error "Docker is not responding (timed out)"
            echo ""
            print_error "╔════════════════════════════════════════════════════════════╗"
            print_error "║  Docker Desktop is not running!                            ║"
            print_error "╠════════════════════════════════════════════════════════════╣"
            print_error "║  Please start Docker Desktop first:                        ║"
            print_error "║  • Open Docker Desktop from Applications                   ║"
            print_error "║  • Wait for it to fully start (whale icon stops animating) ║"
            print_error "║  • Then run this script again                              ║"
            print_error "╚════════════════════════════════════════════════════════════╝"
            echo ""
            print_info "Or run with --skip-docker if the selected environment uses external services"
            exit 1
        fi
        sleep 1
        WAIT_COUNT=$((WAIT_COUNT + 1))
    done

    wait $DOCKER_PID
    if [ $? -ne 0 ]; then
        print_error "Docker is not running"
        echo ""
        print_error "╔════════════════════════════════════════════════════════════╗"
        print_error "║  Docker Desktop is not running!                            ║"
        print_error "╠════════════════════════════════════════════════════════════╣"
        print_error "║  Please start Docker Desktop first:                        ║"
        print_error "║  • Open Docker Desktop from Applications                   ║"
        print_error "║  • Wait for it to fully start (whale icon stops animating) ║"
        print_error "║  • Then run this script again                              ║"
        print_error "╚════════════════════════════════════════════════════════════╝"
        echo ""
        print_info "Or run with --skip-docker if the selected environment uses external services"
        exit 1
    fi

    print_success "Docker is installed and running"
}

# Start Docker services
start_docker() {
    if [ "$SKIP_DOCKER" = true ]; then
        print_section "Skipping Docker Startup"
        print_info "Assuming required services are already available"
        return
    fi

    print_section "Starting Docker Services"

    cd "$BACKEND_DIR"

    if run_compose ps | grep -q "Up"; then
        print_info "Docker containers are already running"
        print_info "Stopping existing containers..."
        run_compose down
    fi

    print_info "Starting Docker containers..."
    run_compose up -d

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

    POSTGRES_HOST=${POSTGRES_HOST:-localhost}
    POSTGRES_PORT=${POSTGRES_PORT:-5432}
    POSTGRES_USER=${POSTGRES_USER:-root}

    print_info "Checking PostgreSQL connection at $POSTGRES_HOST:$POSTGRES_PORT..."

    MAX_RETRIES=30
    RETRY_COUNT=0

    CONTAINER_ID=$(run_compose ps -q postgres 2>/dev/null)

    if [ -z "$CONTAINER_ID" ]; then
        print_warning "Could not find postgres container via Docker Compose"
        print_info "Trying to connect directly via pg_isready..."

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

ensure_backend_dependencies() {
    print_section "Checking Backend Dependencies"

    cd "$BACKEND_DIR"

    if ! command -v pnpm &> /dev/null; then
        print_error "pnpm is not installed"
        print_info "Please install pnpm: npm install -g pnpm"
        exit 1
    fi

    NEEDS_INSTALL=false

    if [ ! -d "node_modules" ]; then
        NEEDS_INSTALL=true
    else
        INSTALLED_PRISMA_VERSION=$(node -p "require('./node_modules/prisma/package.json').version" 2>/dev/null || echo "")
        INSTALLED_PRISMA_MAJOR=${INSTALLED_PRISMA_VERSION%%.*}

        if [ -z "$INSTALLED_PRISMA_VERSION" ] || [ -z "$INSTALLED_PRISMA_MAJOR" ] || [ "$INSTALLED_PRISMA_MAJOR" -lt 7 ]; then
            NEEDS_INSTALL=true
        fi
    fi

    if [ "$NEEDS_INSTALL" = true ]; then
        print_info "Installing dependencies (including Prisma 7)..."
        pnpm install
    else
        print_success "Dependencies are already installed"
    fi
}

# Setup database
setup_database() {
    if [ "$SELECTED_ENV" != "local" ]; then
        print_section "Skipping Local Database Bootstrap"
        print_info "Environment '$SELECTED_ENV' will use its configured external services"
        return
    fi

    print_section "Setting Up Database"

    cd "$BACKEND_DIR"

    if [ -d "prisma/migrations" ] && [ "$(ls -A prisma/migrations)" ]; then
        print_info "Running database migrations..."
        pnpm exec prisma migrate deploy
    else
        print_info "No migrations found. Pushing database schema..."
        pnpm exec prisma db push --force-reset
    fi

    print_info "Generating Prisma Client..."
    pnpm run prisma:generate

    print_success "Database setup completed successfully"
}

# Seed database
seed_database() {
    if [ "$SKIP_SEED" = true ]; then
        print_info "Seed step enabled: no"
        print_section "Skipping Database Seeding"
        return
    fi

    print_info "Seed step enabled: yes"

    print_section "Seeding Database"

    cd "$BACKEND_DIR"

    print_info "Running database seed..."
    pnpm run db:seed

    print_success "Database seeded successfully"
}

# Start backend server
start_backend_server() {
    print_section "Starting Backend Server"

    cd "$BACKEND_DIR"

    print_info "Selected environment: $SELECTED_ENV"
    print_info "Public base URL: ${PUBLIC_BASE_URL:-http://localhost:${PORT:-3000}}"
    print_info "Starting NestJS backend in development mode..."
    echo ""

    pnpm run start:dev &
    BACKEND_PID=$!

    print_success "Backend started (PID: $BACKEND_PID)"
    print_info "Press Ctrl+C to stop the backend"
    echo ""

    wait $BACKEND_PID
    BACKEND_PID=""
    cleanup_temp_env_file
}

# Main function
main() {
    echo ""
    echo -e "${GREEN}╔════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║   Palakat Backend Environment Runner   ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════╝${NC}"
    echo ""

    ask_interactive_options
    apply_environment_defaults
    check_backend_directory
    check_env_file
    prepare_active_environment
    check_docker
    start_docker
    wait_for_postgres
    ensure_backend_dependencies
    setup_database
    seed_database
    start_backend_server
}

# Run main function
main
