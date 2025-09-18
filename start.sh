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

# Pull latest images
print_step "Pulling latest Docker images..."
docker-compose pull

# Build and start services
print_step "Building and starting services..."
docker-compose up --build -d

# Wait for services to be healthy
print_step "Waiting for services to be ready..."
sleep 10

# Check service status
print_step "Checking service status..."
docker-compose ps

print_header "🎉 Environment Ready!"

echo -e "${GREEN}${BOLD}Available Services:${NC}"

# Read port values from .env file
CORE_PORT=$(grep "^CORE_PORT=" .env | cut -d'=' -f2 || echo "3000")
DB_PORT=$(grep "^POSTGRES_PORT=" .env | cut -d'=' -f2 || echo "5432")
PGADMIN_PORT=$(grep "^PGADMIN_PORT=" .env | cut -d'=' -f2 || echo "8080")

# Table for Available Services
echo -e "${CYAN}${BOLD}"
printf "  %-15s | %-35s\n" "Service" "URL/Address"
echo    "  ---------------+-----------------------------------"
printf "  Core App       | ${WHITE}http://localhost:%s${CYAN}\n" "$CORE_PORT"
printf "  PostgreSQL     | ${WHITE}localhost:%s${CYAN}\n" "$DB_PORT"
printf "  pgAdmin        | ${WHITE}http://localhost:%s${CYAN}\n" "$PGADMIN_PORT"
echo -e "${NC}"

# Database Credentials Table
echo -e "\n${YELLOW}${BOLD}Database Credentials:${NC}"
DB_NAME=$(grep "^POSTGRES_DATABASE=" .env | cut -d'=' -f2 || echo "panchapp_db")
DB_USER=$(grep "^POSTGRES_USER=" .env | cut -d'=' -f2 || echo "panchapp_user")
DB_PASS=$(grep "^POSTGRES_PASSWORD=" .env | cut -d'=' -f2 || echo "panchapp_password")

echo -e "${PURPLE}${BOLD}"
printf "  %-10s | %-30s\n" "Field" "Value"
echo    "  ----------+------------------------------"
printf "  Database  | ${WHITE}%-30s${PURPLE}\n" "$DB_NAME"
printf "  Username  | ${WHITE}%-30s${PURPLE}\n" "$DB_USER"
printf "  Password  | ${WHITE}%-30s${PURPLE}\n" "$DB_PASS"
echo -e "${NC}"

# pgAdmin Credentials Table
echo -e "\n${YELLOW}${BOLD}pgAdmin Credentials:${NC}"
PGADMIN_EMAIL=$(grep "^PGADMIN_DEFAULT_EMAIL=" .env | cut -d'=' -f2 || echo "admin@panchapp.com")
PGADMIN_PASS=$(grep "^PGADMIN_DEFAULT_PASSWORD=" .env | cut -d'=' -f2 || echo "admin123")

echo -e "${PURPLE}${BOLD}"
printf "  %-10s | %-30s\n" "Field" "Value"
echo    "  ----------+------------------------------"
printf "  Email     | ${WHITE}%-30s${PURPLE}\n" "$PGADMIN_EMAIL"
printf "  Password  | ${WHITE}%-30s${PURPLE}\n" "$PGADMIN_PASS"
echo -e "${NC}"
