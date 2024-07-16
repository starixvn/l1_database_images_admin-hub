#!/bin/bash
set -xe

REGISTRY_URL=hub.lumigame.com
IMAGE_NAME=admin-hub
IMAGE_MINOR_VERSION=1.1
IMAGE_PATCH_VERSION=1.1.4-rc.1

docker build \
    --file docker/Dockerfile \
    --tag ${REGISTRY_URL}/ldb/${IMAGE_NAME}:${IMAGE_PATCH_VERSION} \
    -- .
docker tag ${REGISTRY_URL}/ldb/${IMAGE_NAME}:${IMAGE_PATCH_VERSION} ${REGISTRY_URL}/ldb/${IMAGE_NAME}:latest-rc

docker push ${REGISTRY_URL}/ldb/${IMAGE_NAME}:${IMAGE_PATCH_VERSION}
docker push ${REGISTRY_URL}/ldb/${IMAGE_NAME}:latest-rc
