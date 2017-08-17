#!/bin/bash

set -e

function build_push() {
    local TARGET_IMAGE=$1
    local IMAGE_TAG=$2

    docker build -t ${TARGET_IMAGE}:latest .
    docker tag ${TARGET_IMAGE}:latest ${TARGET_IMAGE}:${IMAGE_TAG}
    docker push ${TARGET_IMAGE}:${IMAGE_TAG}
    docker push ${TARGET_IMAGE}:latest
}

yum -y install docker 
service docker start

[ -f jenkins-env ] && cat jenkins-env | grep -e GIT -e DEVSHIFT > inherit-env
[ -f inherit-env ] && . inherit-env
TAG=$(echo $GIT_COMMIT | cut -c1-${DEVSHIFT_TAG_LEN})
REGISTRY="push.registry.devshift.net"

if [ -n "${DEVSHIFT_USERNAME}" -a -n "${DEVSHIFT_PASSWORD}" ]; then
    docker login -u ${DEVSHIFT_USERNAME} -p ${DEVSHIFT_PASSWORD} ${REGISTRY}
else
    echo "Could not login, missing credentials for the registry"
fi

(
    cd pcp-node-collector
    build_push ${REGISTRY}/perf/pcp-node-collector ${TAG}
)
(
    cd pcp-central-logger
    build_push  ${REGISTRY}/perf/pcp-central-logger ${TAG}
)
(
    cd pcp-central-webapi
    build_push  ${REGISTRY}/perf/pcp-central-webapi ${TAG}
)
(
    cd webapi-guard
    build_push  ${REGISTRY}/perf/webapi-guard ${TAG}
)
(
    cd mm-zabbix-relay
    build_push  ${REGISTRY}/perf/mm-zabbix-relay ${TAG}
)
