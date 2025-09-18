#!/bin/bash

# Bash script to stop the local development environment

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

print_info() {
    echo -e "${CYAN}  ℹ️  $1${NC}"
}

print_header "🛑 Stopping PanchApp Local Development Environment"

# Read control variables to determine which profiles were active
print_step "Reading container control variables..."

# Source the .env file to get the control variables
if [ -f ".env" ]; then
    source .env
else
    print_info "No .env file found, stopping all services"
    docker-compose down
    exit 0
fi

# Build profile list based on control variables
PROFILES=""

if [ "${MOUNT_POSTGRES_DATABASE:-true}" = "true" ]; then
    PROFILES="$PROFILES postgres"
fi

if [ "${MOUNT_CORE_SERVICE:-false}" = "true" ]; then
    PROFILES="$PROFILES core"
fi

if [ "${MOUNT_PGADMIN:-true}" = "true" ]; then
    PROFILES="$PROFILES pgadmin"
fi

# Build docker-compose command with multiple --profile flags
build_docker_compose_cmd() {
    local cmd="docker-compose"
    for profile in $PROFILES; do
        cmd="$cmd --profile $profile"
    done
    echo "$cmd"
}

# Stop services with selected profiles
if [ -n "$PROFILES" ]; then
    print_step "Stopping services with profiles: $PROFILES..."
    DOCKER_COMPOSE_CMD=$(build_docker_compose_cmd)
    $DOCKER_COMPOSE_CMD down
else
    print_step "No active profiles found, stopping all services..."
    docker-compose down
fi

print_header "✅ Environment Stopped Successfully!"

echo -e "${YELLOW}${BOLD}💡 Additional Options:${NC}"
echo -e "${PURPLE}  Remove volumes (database data):  ${WHITE}docker-compose down -v${NC}"
echo -e "${PURPLE}  Remove images:                   ${WHITE}docker-compose down --rmi all${NC}"
echo -e "${PURPLE}  Start environment again:         ${WHITE}./start.sh${NC}"
echo -e "${CYAN}${BOLD}═══════════════════════════════════════════════════════════════${NC}\n"
