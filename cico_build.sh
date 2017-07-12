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

[ -f jenkins-env ] && cat jenkins-env | grep -e GIT > inherit-env
[ -f inherit-env ] && . inherit-env
TAG=$(echo $GIT_COMMIT | cut -c1-6)

(
    cd grafana-hawkular
    build_push registry.devshift.net/perf/osd-monitor ${TAG}
)
(
    cd pcp-node-collector
    build_push registry.devshift.net/perf/pcp-node-collector ${TAG}
)
(
    cd pcp-central-logger
    build_push  registry.devshift.net/perf/pcp-central-logger ${TAG}
)
(
    cd pcp-central-webapi
    build_push  registry.devshift.net/perf/pcp-central-webapi ${TAG}
)
(
    cd webapi-guard
    build_push  registry.devshift.net/perf/webapi-guard ${TAG}
)
(
    cd mm-zabbix-relay
    build_push  registry.devshift.net/perf/mm-zabbix-relay ${TAG}
)
