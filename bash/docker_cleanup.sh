#!/bin/bash

# Script to clean up Docker environment

echo "Starting Docker cleanup..."

# Remove stopped containers
echo "Removing stopped containers..."
docker container prune -f

# Remove unused images
echo "Removing unused images..."
docker image prune -a -f

# Remove dangling volumes
echo "Removing dangling volumes..."
docker volume prune -f

# Check Docker disk usage
echo "Docker disk usage after cleanup:"
docker system df

echo "Docker cleanup completed!"