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

# Stop all services
print_step "Stopping all services..."
docker-compose down

print_header "✅ Environment Stopped Successfully!"

echo -e "${YELLOW}${BOLD}💡 Additional Options:${NC}"
echo -e "${PURPLE}  Remove volumes (database data):  ${WHITE}docker-compose down -v${NC}"
echo -e "${PURPLE}  Remove images:                   ${WHITE}docker-compose down --rmi all${NC}"
echo -e "${PURPLE}  Start environment again:         ${WHITE}./start.sh${NC}"
echo -e "${CYAN}${BOLD}═══════════════════════════════════════════════════════════════${NC}\n"
