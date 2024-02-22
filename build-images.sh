!#/bin/bash
set -x

REGISTRY_URL=hub.lumigame.com
IMAGE_NAME=admin-hub
IMAGE_VERSION=1.0

docker build \
    --file docker/Dockerfile \
    --tag ${REGISTRY_URL}/ldb/${IMAGE_NAME}:${IMAGE_VERSION} \
    -- .
docker tag ${REGISTRY_URL}/ldb/${IMAGE_NAME}:${IMAGE_VERSION} ${REGISTRY_URL}/ldb/${IMAGE_NAME}:latest

for UBUNTU_DISTRO in focal jammy; do
    docker build \
        --file docker/ubuntu/${UBUNTU_DISTRO}/Dockerfile \
        --tag ${REGISTRY_URL}/ldb/${IMAGE_NAME}:${IMAGE_VERSION}-${UBUNTU_DISTRO} \
        -- .
    docker tag ${REGISTRY_URL}/ldb/${IMAGE_NAME}:${IMAGE_VERSION}-${UBUNTU_DISTRO} ${REGISTRY_URL}/ldb/${IMAGE_NAME}:latest-${UBUNTU_DISTRO}
done

docker push --all-tags ${REGISTRY_URL}/ldb/${IMAGE_NAME}
