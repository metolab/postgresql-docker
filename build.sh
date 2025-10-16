#!/bin/bash
set -e

# Default PostgreSQL version
POSTGRES_VERSION=${1:-15}
IMAGE_NAME=${2:-ghcr.io/$(basename $(git config remote.origin.url 2>/dev/null || echo "your-username"))/postgres-roaringbitmap}

# Show usage
if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    echo "Usage: $0 [POSTGRES_VERSION] [IMAGE_NAME]"
    echo "Example: $0 15 ghcr.io/username/postgres-roaringbitmap"
    echo "Default PostgreSQL version: 15"
    echo "Default image name: ghcr.io/\$(username)/postgres-roaringbitmap"
    exit 0
fi

echo "Building PostgreSQL ${POSTGRES_VERSION} with pg_roaringbitmap extension..."
echo "Image name: ${IMAGE_NAME}:${POSTGRES_VERSION}"

# Build the Docker image
docker build \
    --build-arg POSTGRES_VERSION=${POSTGRES_VERSION} \
    -t ${IMAGE_NAME}:${POSTGRES_VERSION} \
    -t ${IMAGE_NAME}:latest \
    .

echo "Build completed successfully!"
echo "Image tagged as:"
echo "  - ${IMAGE_NAME}:${POSTGRES_VERSION}"
echo "  - ${IMAGE_NAME}:latest"
echo ""
echo "To run the container:"
echo "  docker run -d --name postgres-${POSTGRES_VERSION} -e POSTGRES_PASSWORD=mysecretpassword -p 5432:5432 ${IMAGE_NAME}:${POSTGRES_VERSION}"