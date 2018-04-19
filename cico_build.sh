#!/bin/bash

set -e

function build_push() {
    local TARGET_IMAGE=$1
    local IMAGE_TAG=$2

    docker build -t ${TARGET_IMAGE}:latest -f ${DOCKERFILE} .
    docker tag ${TARGET_IMAGE}:latest ${TARGET_IMAGE}:${IMAGE_TAG}
    docker push ${TARGET_IMAGE}:${IMAGE_TAG}
    docker push ${TARGET_IMAGE}:latest
}

yum -y install docker 
service docker start

[ -f jenkins-env ] && cat jenkins-env | grep -e GIT -e DEVSHIFT > inherit-env
[ -f inherit-env ] && . inherit-env

# TARGET variable gives ability to switch context for building rhel based images, default is "centos"
# If CI slave is configured with TARGET="rhel" RHEL based images should be generated then.
TARGET=${TARGET:-"centos"}

TAG=$(echo $GIT_COMMIT | cut -c1-${DEVSHIFT_TAG_LEN})

if [ "$TARGET" == "rhel" ]; then
    DOCKERFILE="Dockerfile.rhel"
    REGISTRY=${DOCKER_REGISTRY:-"push.registry.devshift.net/osio-prod"}
else
    DOCKERFILE="Dockerfile"
    REGISTRY="push.registry.devshift.net"
fi

if [ -n "${DEVSHIFT_USERNAME}" -a -n "${DEVSHIFT_PASSWORD}" ]; then
    docker login -u "${DEVSHIFT_USERNAME}" -p "${DEVSHIFT_PASSWORD}" "${REGISTRY}"
else
    echo "Could not login, missing credentials for the registry"
fi

for subdir in pcp-node-collector \
                  pcp-central-logger \
                  pcp-central-webapi \
                  pcp-webapi-guard \
                  pcp-bayesian-central-logger \
                  pcp-bayesian-webapi-guard \
                  pcp-postgresql-monitor \
                  mm-zabbix-relay \
                  oso-pcp-prometheus \
                  oso-webapi-guard \
                  oso-central-logger \
                  oso-central-webapi-guard
do
    (cd $subdir; build_push ${REGISTRY}/perf/$subdir ${TAG})
done
