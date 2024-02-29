#!/bin/bash

# Define variables
DOCKER_USERNAME="admin"
DOCKER_PASSWORD="Harbor12345"
IMAGE_NAME="backend"
IMAGE_TAG="latest"
HARBOR_URL="192.168.226.131"
DOCKER_REPO="backend"

# Login to Harbor
docker login -u "$DOCKER_USERNAME" -p "$DOCKER_PASSWORD" "$HARBOR_URL"

# Build Docker image
docker build -t "$DOCKER_REPO" .

# Tag the image with Harbor URL
docker tag "$DOCKER_REPO" "$HARBOR_URL/propsoft-backend-side/$IMAGE_NAME:$IMAGE_TAG"

# Push Docker image to Harbor
docker push "$HARBOR_URL/propsoft-backend-side/$IMAGE_NAME:$IMAGE_TAG"
