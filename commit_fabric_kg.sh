#!/bin/bash

# Script to commit the fabric-kg Neo4j container to a Docker image
# This saves the current state of the database (nodes, relationships, indexes) into a reusable image.

CONTAINER_NAME="fabric-kg"
IMAGE_NAME="fabric-kg"

echo "Checking for container '${CONTAINER_NAME}'..."

# Check if container exists
if ! docker ps -a --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
    echo "❌ Error: Container '${CONTAINER_NAME}' does not exist."
    echo "Please ensure the container is created before running this script."
    exit 1
fi

# Check if container is running
if docker ps --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
    echo "ℹ️  Container is currently running. The commit will pause it momentarily."
else
    echo "ℹ️  Container is stopped. Proceeding with commit."
fi

echo "📦 Committing container '${CONTAINER_NAME}' to image '${IMAGE_NAME}'..."
echo "This may take a moment depending on the database size..."

# Commit the container
if docker commit "${CONTAINER_NAME}" "${IMAGE_NAME}"; then
    echo "✅ Successfully committed container to image '${IMAGE_NAME}'"
    echo ""
    echo "To run this saved image later, use:"
    echo "docker run -d \\"
    echo "  --name fabric-kg-restored \\"
    echo "  -p 7687:7687 \\"
    echo "  -p 7474:7474 \\"
    echo "  -e NEO4J_AUTH=neo4j/password \\"
    echo "  ${IMAGE_NAME}"
else
    echo "❌ Failed to commit container."
    exit 1
fi
