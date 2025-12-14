#!/bin/bash

# Neo4j Docker Container Setup and Run Script
# This script manages the Neo4j Docker container with optimized settings for the knowledge graph

set -e  # Exit on error

# Configuration
CONTAINER_NAME="neo4j"
IMAGE_NAME="neo4j:5.15"
PORT_BOLT="7687"
PORT_HTTP="7474"
NEO4J_USER="neo4j"
NEO4J_PASSWORD="password"
HEAP_SIZE="2G"
PAGECACHE_SIZE="1G"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

# Function to check if Docker is installed
check_docker() {
    if ! command -v docker &> /dev/null; then
        print_error "Docker is not installed or not in PATH"
        echo "Please install Docker from https://www.docker.com"
        exit 1
    fi
    print_success "Docker found"
}

# Function to check if container is running
is_container_running() {
    docker ps --filter "name=${CONTAINER_NAME}" --filter "status=running" -q
}

# Function to check if container exists
does_container_exist() {
    docker ps -a --filter "name=${CONTAINER_NAME}" -q
}

# Function to start the Neo4j container
start_container() {
    print_info "Starting Neo4j container..."
    
    if [ -n "$(does_container_exist)" ]; then
        print_warning "Container '${CONTAINER_NAME}' already exists"
        
        if [ -z "$(is_container_running)" ]; then
            print_info "Container is stopped. Starting it now..."
            docker start ${CONTAINER_NAME}
            print_success "Container started successfully"
        else
            print_warning "Container is already running"
        fi
    else
        print_info "Creating new Neo4j container..."
        docker run -d \
            --name ${CONTAINER_NAME} \
            -p ${PORT_BOLT}:7687 \
            -p ${PORT_HTTP}:7474 \
            -e NEO4J_AUTH=${NEO4J_USER}/${NEO4J_PASSWORD} \
            -e NEO4J_dbms_memory_heap_initial__size=${HEAP_SIZE} \
            -e NEO4J_dbms_memory_heap_max__size=${HEAP_SIZE} \
            -e NEO4J_dbms_memory_pagecache_size=${PAGECACHE_SIZE} \
            -e NEO4J_ACCEPT_LICENSE_AGREEMENT=yes \
            ${IMAGE_NAME}
        
        if [ $? -eq 0 ]; then
            print_success "Container created successfully"
        else
            print_error "Failed to create container"
            exit 1
        fi
    fi
}

# Function to wait for Neo4j to be ready
wait_for_neo4j() {
    print_info "Waiting for Neo4j to be ready..."
    local max_attempts=30
    local attempt=0
    
    while [ $attempt -lt $max_attempts ]; do
        if docker exec ${CONTAINER_NAME} cypher-shell -u ${NEO4J_USER} -p ${NEO4J_PASSWORD} "RETURN 1" &> /dev/null; then
            print_success "Neo4j is ready!"
            return 0
        fi
        
        attempt=$((attempt + 1))
        echo -ne "\r  Attempt $attempt/$max_attempts..."
        sleep 1
    done
    
    print_error "Neo4j failed to start within timeout"
    return 1
}

# Function to display connection information
display_info() {
    echo ""
    echo "========================================"
    print_success "Neo4j Container Information"
    echo "========================================"
    echo ""
    print_info "Container Name: ${CONTAINER_NAME}"
    print_info "Image: ${IMAGE_NAME}"
    print_info "Bolt Port: bolt://localhost:${PORT_BOLT}"
    print_info "HTTP Port: http://localhost:${PORT_HTTP}"
    print_info "Username: ${NEO4J_USER}"
    print_info "Password: ${NEO4J_PASSWORD}"
    echo ""
    print_info "Access Neo4j Browser at: http://localhost:${PORT_HTTP}"
    print_info "Python connection string:"
    echo "   bolt://localhost:${PORT_BOLT}"
    echo ""
}

# Function to stop container
stop_container() {
    if [ -n "$(is_container_running)" ]; then
        print_info "Stopping Neo4j container..."
        docker stop ${CONTAINER_NAME}
        print_success "Container stopped"
    else
        print_warning "Container is not running"
    fi
}

# Function to remove container
remove_container() {
    if [ -n "$(does_container_exist)" ]; then
        if [ -n "$(is_container_running)" ]; then
            docker stop ${CONTAINER_NAME}
        fi
        print_info "Removing Neo4j container..."
        docker rm ${CONTAINER_NAME}
        print_success "Container removed"
    else
        print_warning "Container does not exist"
    fi
}

# Function to view logs
view_logs() {
    print_info "Showing Neo4j logs (Press Ctrl+C to exit)..."
    docker logs -f ${CONTAINER_NAME}
}

# Function to check container status
check_status() {
    if [ -n "$(is_container_running)" ]; then
        print_success "Container '${CONTAINER_NAME}' is running"
        echo ""
        docker ps --filter "name=${CONTAINER_NAME}"
    elif [ -n "$(does_container_exist)" ]; then
        print_warning "Container '${CONTAINER_NAME}' exists but is not running"
    else
        print_warning "Container '${CONTAINER_NAME}' does not exist"
    fi
}

# Main script logic
main() {
    # Check for command argument
    COMMAND=${1:-"start"}
    
    case "${COMMAND}" in
        start)
            check_docker
            start_container
            wait_for_neo4j && display_info
            ;;
        stop)
            check_docker
            stop_container
            ;;
        restart)
            check_docker
            stop_container
            sleep 2
            start_container
            wait_for_neo4j && display_info
            ;;
        remove)
            check_docker
            print_warning "This will delete the Neo4j container and all its data"
            read -p "Are you sure? (yes/no): " confirm
            if [ "$confirm" = "yes" ]; then
                remove_container
            else
                print_info "Cancelled"
            fi
            ;;
        status)
            check_docker
            check_status
            ;;
        logs)
            check_docker
            view_logs
            ;;
        *)
            echo "Neo4j Docker Management Script"
            echo ""
            echo "Usage: $0 [command]"
            echo ""
            echo "Commands:"
            echo "  start      Start or create Neo4j container (default)"
            echo "  stop       Stop the running container"
            echo "  restart    Restart the container"
            echo "  status     Show container status"
            echo "  logs       View container logs (follow mode)"
            echo "  remove     Remove the container and all data"
            echo ""
            echo "Examples:"
            echo "  $0 start"
            echo "  $0 stop"
            echo "  $0 restart"
            echo "  $0 status"
            echo "  $0 logs"
            echo "  $0 remove"
            ;;
    esac
}

# Run main function
main "$@"
