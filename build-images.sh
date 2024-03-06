!#/bin/bash
set -x

REGISTRY_URL=hub.lumigame.com
IMAGE_NAME=admin-hub
IMAGE_MINOR_VERSION=1.0
IMAGE_PATCH_VERSION=1.0.3

docker build \
    --file docker/Dockerfile \
    --tag ${REGISTRY_URL}/ldb/${IMAGE_NAME}:${IMAGE_PATCH_VERSION} \
    -- .
docker tag ${REGISTRY_URL}/ldb/${IMAGE_NAME}:${IMAGE_PATCH_VERSION} ${REGISTRY_URL}/ldb/${IMAGE_NAME}:${IMAGE_MINOR_VERSION}
docker tag ${REGISTRY_URL}/ldb/${IMAGE_NAME}:${IMAGE_PATCH_VERSION} ${REGISTRY_URL}/ldb/${IMAGE_NAME}:latest

for UBUNTU_DISTRO in focal jammy; do
    docker build \
        --file docker/ubuntu/${UBUNTU_DISTRO}/Dockerfile \
        --tag ${REGISTRY_URL}/ldb/${IMAGE_NAME}:${IMAGE_PATCH_VERSION}-${UBUNTU_DISTRO} \
        -- .
    docker tag ${REGISTRY_URL}/ldb/${IMAGE_NAME}:${IMAGE_PATCH_VERSION}-${UBUNTU_DISTRO} ${REGISTRY_URL}/ldb/${IMAGE_NAME}:${IMAGE_MINOR_VERSION}-${UBUNTU_DISTRO}
    docker tag ${REGISTRY_URL}/ldb/${IMAGE_NAME}:${IMAGE_PATCH_VERSION}-${UBUNTU_DISTRO} ${REGISTRY_URL}/ldb/${IMAGE_NAME}:latest-${UBUNTU_DISTRO}
done

docker push --all-tags ${REGISTRY_URL}/ldb/${IMAGE_NAME}

git reset HEAD -- . \
    && git add . \
    && git commit -m "chore(publish): \`${IMAGE_NAME}:${IMAGE_PATCH_VERSION}\`"

git push origin --delete "${IMAGE_MINOR_VERSION}"; \
    git tag -d "${IMAGE_MINOR_VERSION}"; \
    git tag -s "${IMAGE_MINOR_VERSION}" -m ""; \
    git tag -s "${IMAGE_PATCH_VERSION}" -m ""; \
    git push origin "${IMAGE_MINOR_VERSION}" "${IMAGE_PATCH_VERSION}"
