#!/bin/bash

# Bash script to start the local development environment

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Function to print colored text
print_header() {
    echo -e "\n${CYAN}${BOLD}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}${BOLD}  $1${NC}"
    echo -e "${CYAN}${BOLD}═══════════════════════════════════════════════════════════════${NC}\n"
}

print_step() {
    echo -e "${BLUE}${BOLD}➤ ${NC} ${WHITE}$1${NC}"
}

print_success() {
    echo -e "${GREEN}  ✅ $1${NC}"
}

print_error() {
    echo -e "${RED}  ❌ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}  ⚠️  $1${NC}"
}

print_info() {
    echo -e "${CYAN}  ℹ️  $1${NC}"
}

print_header "🚀 Starting PanchApp Local Development Environment"

# Check if Docker is running
print_step "Checking Docker status..."
if ! docker info >/dev/null 2>&1; then
    print_error "Docker is not running. Please start Docker first."
    exit 1
fi
print_success "Docker is running"

# Check if docker-compose is available
print_step "Checking docker-compose availability..."
if ! command -v docker-compose &> /dev/null; then
    print_error "docker-compose is not available. Please install Docker Compose."
    exit 1
fi
print_success "docker-compose is available"

# Check if .env file exists
print_step "Checking for .env file..."
if [ ! -f ".env" ]; then
    print_error ".env file not found!"
    print_info "Creating .env file from env.example..."
    if [ -f "env.example" ]; then
        cp env.example .env
        print_success ".env file created successfully"
        print_warning "Please review and customize the .env file if needed"
    else
        print_error "env.example file not found either!"
        echo -e "${RED}Please create a .env file with your environment variables${NC}"
        exit 1
    fi
else
    print_success ".env file found"
fi

# Create logs directory if it doesn't exist
if [ ! -d "logs" ]; then
    mkdir logs
    print_info "Created logs directory"
fi

# Create init-db directory if it doesn't exist
if [ ! -d "init-db" ]; then
    mkdir init-db
    print_info "Created init-db directory"
fi

# Read control variables and determine which profiles to activate
print_step "Reading container control variables..."

# Source the .env file to get the control variables
source .env

# Build profile list based on control variables
PROFILES=""

if [ "${MOUNT_POSTGRES_DATABASE:-true}" = "true" ]; then
    PROFILES="$PROFILES postgres"
    print_success "PostgreSQL database will be mounted"
else
    print_warning "PostgreSQL database will NOT be mounted"
fi

if [ "${MOUNT_CORE_SERVICE:-false}" = "true" ]; then
    PROFILES="$PROFILES core"
    print_success "Core service will be mounted"
else
    print_warning "Core service will NOT be mounted"
fi

if [ "${MOUNT_PGADMIN:-true}" = "true" ]; then
    PROFILES="$PROFILES pgadmin"
    print_success "pgAdmin will be mounted"
else
    print_warning "pgAdmin will NOT be mounted"
fi

# Check if any profiles are selected
if [ -z "$PROFILES" ]; then
    print_error "No services are enabled to be mounted!"
    exit 1
fi

# Build docker-compose command with multiple --profile flags
build_docker_compose_cmd() {
    local cmd="docker-compose"
    for profile in $PROFILES; do
        cmd="$cmd --profile $profile"
    done
    echo "$cmd"
}

# Pull latest images for active profiles
print_step "Pulling latest Docker images for active services..."
DOCKER_COMPOSE_CMD=$(build_docker_compose_cmd)
$DOCKER_COMPOSE_CMD pull

# Build and start services with selected profiles
print_step "Building and starting services with profiles: $PROFILES..."

# If both postgres and core are enabled, start postgres first, then core
if [[ "$PROFILES" == *"postgres"* ]] && [[ "$PROFILES" == *"core"* ]]; then
    print_info "Starting PostgreSQL first (dependency for core service)..."
    docker-compose --profile postgres up --build -d

    print_info "Waiting for PostgreSQL to be healthy..."
    sleep 15

    print_info "Starting core service..."
    docker-compose --profile core up --build -d

    # Start any remaining services (like pgadmin)
    REMAINING_PROFILES=$(echo $PROFILES | sed 's/postgres//g' | sed 's/core//g' | xargs)
    if [ -n "$REMAINING_PROFILES" ]; then
        print_info "Starting remaining services: $REMAINING_PROFILES"
        REMAINING_CMD="docker-compose"
        for profile in $REMAINING_PROFILES; do
            REMAINING_CMD="$REMAINING_CMD --profile $profile"
        done
        $REMAINING_CMD up --build -d
    fi
else
    # Start all services at once if no dependency issues
    $DOCKER_COMPOSE_CMD up --build -d
fi

# Wait for services to be healthy
print_step "Waiting for services to be ready..."
sleep 10

# Check service status
print_step "Checking service status..."
$DOCKER_COMPOSE_CMD ps

print_header "🎉 Environment Ready!"

echo -e "${GREEN}${BOLD}Available Services:${NC}"

# Read port values from environment variables (already sourced from .env)
CORE_PORT=${CORE_PORT:-3000}
DB_PORT=${POSTGRES_PORT:-5432}
PGADMIN_PORT=${PGADMIN_PORT:-8080}

# Table for Available Services - only show mounted services
echo -e "${CYAN}${BOLD}"
printf "  %-15s | %-35s\n" "Service" "URL/Address"
echo    "  ---------------+-----------------------------------"

if [ "${MOUNT_POSTGRES_DATABASE:-true}" = "true" ]; then
    printf "  PostgreSQL     | ${WHITE}localhost:%s${CYAN}\n" "$DB_PORT"
fi

if [ "${MOUNT_CORE_SERVICE:-false}" = "true" ]; then
    printf "  Core App       | ${WHITE}http://localhost:%s${CYAN}\n" "$CORE_PORT"
fi

if [ "${MOUNT_PGADMIN:-true}" = "true" ]; then
    printf "  pgAdmin        | ${WHITE}http://localhost:%s${CYAN}\n" "$PGADMIN_PORT"
fi

echo -e "${NC}"

# Database Credentials Table - only show if PostgreSQL is mounted
if [ "${MOUNT_POSTGRES_DATABASE:-true}" = "true" ]; then
    echo -e "\n${YELLOW}${BOLD}Database Credentials:${NC}"
    DB_NAME=${POSTGRES_DATABASE:-panchapp_db}
    DB_USER=${POSTGRES_USER:-panchapp_user}
    DB_PASS=${POSTGRES_PASSWORD:-panchapp_password}

    echo -e "${PURPLE}${BOLD}"
    printf "  %-10s | %-30s\n" "Field" "Value"
    echo    "  ----------+------------------------------"
    printf "  Database  | ${WHITE}%-30s${PURPLE}\n" "$DB_NAME"
    printf "  Username  | ${WHITE}%-30s${PURPLE}\n" "$DB_USER"
    printf "  Password  | ${WHITE}%-30s${PURPLE}\n" "$DB_PASS"
    echo -e "${NC}"
fi

# pgAdmin Credentials Table - only show if pgAdmin is mounted
if [ "${MOUNT_PGADMIN:-true}" = "true" ]; then
    echo -e "\n${YELLOW}${BOLD}pgAdmin Credentials:${NC}"
    PGADMIN_EMAIL=${PGADMIN_DEFAULT_EMAIL:-admin@panchapp.com}
    PGADMIN_PASS=${PGADMIN_DEFAULT_PASSWORD:-admin123}

    echo -e "${PURPLE}${BOLD}"
    printf "  %-10s | %-30s\n" "Field" "Value"
    echo    "  ----------+------------------------------"
    printf "  Email     | ${WHITE}%-30s${PURPLE}\n" "$PGADMIN_EMAIL"
    printf "  Password  | ${WHITE}%-30s${PURPLE}\n" "$PGADMIN_PASS"
    echo -e "${NC}"
fi
