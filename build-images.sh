#!/usr/bin/env bash

set -eEu -o pipefail

# Replace with your username. Don't push your dev images to redhat-github-actions.
REGISTRY=${RUNNERS_REGISTRY:-quay.io/abryson}
TAG=${RUNNERS_TAG:-latest}

BASE_IMG=${REGISTRY}/runner:${TAG}
BUILDAH_IMG=${REGISTRY}/buildah-runner:${TAG}
K8S_TOOLS_IMG=${REGISTRY}/k8s-tools-runner:${TAG}
JAVA_BUILD_11_IMG=${REGISTRY}/java-build-11-runner:${TAG}
NODEJS_IMG=${REGISTRY}/nodejs-runner:${TAG}
IMAGE_SCAN_IMG=${REGISTRY}/imagescan-runner:${TAG}
JAVA_RUNTIME_11_IMG=${REGISTRY}/java-runtime-11-runner:${TAG}
SONARQUBE_RUNNER_IMG=${REGISTRY}/sonarqube-runner:${TAG}

echo "Base img tag $BASE_IMG"

enabled() {
    [[ $1 == *$2* ]]
}

cd $(dirname $0)

if enabled "$*" base; then
    echo "Building base image..."
    docker build -f ./base/Containerfile -t $BASE_IMG ./base
fi

if enabled "$*" buildah; then
    echo "Building buildah image..."
    docker build -f ./buildah/Containerfile -t $BUILDAH_IMG ./buildah
fi
if enabled "$*" k8s; then
    echo "Building K8s image..."
    docker build -f ./k8s-tools/Containerfile -t $K8S_TOOLS_IMG ./k8s-tools
fi

if enabled "$*" node; then
    echo "Building nodejs image..."
    docker build -f ./node/Containerfile -t $NODEJS_IMG ./node
fi

if enabled "$*" java-build-11; then
    echo "Building java-build-11 image..."
    docker build -f ./java-build-11/Containerfile -t $JAVA_BUILD_11_IMG ./java-build-11
fi

if enabled "$*" java-runtime-11; then
    echo "Building java-runtime-11 image..."
    docker build -f ./java/Containerfile -t $JAVA_RUNTIME_11_IMG ./java
fi

if enabled "$*" imagescan; then
    echo "Building imagescan image..."
    docker build -f ./image-scan/Containerfile -t $IMAGE_SCAN_IMG ./image-scan
fi

if enabled "$*" sonarqube; then
    echo "Building sonarqube image..."
    docker build -f ./docker-sonarqube/Containerfile -t $SONARQUBE_RUNNER_IMG ./docker-sonarqube
fi
if enabled "$*" push; then
    echo "Pushing..."
    docker push $BASE_IMG

    if enabled "$*" buildah; then
        docker push $BUILDAH_IMG
    fi
    if enabled "$*" k8s; then
        docker push $K8S_TOOLS_IMG
    fi
    if enabled "$*" node; then
        docker push $NODEJS_IMG
    fi
    if enabled "$*" java-build-11; then
        docker push $JAVA_BUILD_11_IMG
    fi
    if enabled "$*" java-runtime-11; then
        docker push $JAVA_RUNTIME_11_IMG
    fi
    if enabled "$*" imagescan; then
        docker push $IMAGE_SCAN_IMG
    fi
    if enabled "$*" sonarqube; then
        docker push $SONARQUBE_RUNNER_IMG
    fi
else
    echo "Not pushing. Pass 'push' to push"
fi

echo "$BASE_IMG"
if enabled "$*" buildah; then
    echo "$BUILDAH_IMG"
fi
if enabled "$*" k8s; then
    echo "$K8S_TOOLS_IMG"
fi
if enabled "$*" node; then
    echo "$NODEJS_IMG"
fi
if enabled "$*" java-build-11; then
    echo "$JAVA_BUILD_11_IMG"
fi
if enabled "$*" java-runtime-11; then
    echo "$JAVA_RUNTIME_11_IMG"
fi
if enabled "$*" imagescan; then
    echo "$IMAGE_SCAN_IMG"
fi
if enabled "$*" sonarqube; then
    echo "$SONARQUBE_RUNNER_IMG"
fi

cd - > /dev/null
