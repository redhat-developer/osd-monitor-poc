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

# Retrieve credentials to push the image to the docker hub
eval "$(./env-toolkit load -f jenkins-env.json -r GIT DEVSHIFT ^QUAY)"

REGISTRY="quay.io"

# TARGET variable gives ability to switch context for building rhel based images, default is "centos"
# If CI slave is configured with TARGET="rhel" RHEL based images should be generated then.
TARGET=${TARGET:-"centos"}

TAG=$(echo $GIT_COMMIT | cut -c1-${DEVSHIFT_TAG_LEN})

if [ -n "${QUAY_USERNAME}" -a -n "${QUAY_PASSWORD}" ]; then
    docker login -u "${QUAY_USERNAME}" -p "${QUAY_PASSWORD}" "${REGISTRY}"
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
                  pcp-prometheus-in \
                  mm-zabbix-relay
do
    (
      if [ "$TARGET" = "rhel" ]; then
          DOCKERFILE="Dockerfile.rhel"
          IMAGE="${REGISTRY}/openshiftio/rhel-perf-$subdir"
      else
          DOCKERFILE="Dockerfile"
          IMAGE="${REGISTRY}/openshiftio/perf-$subdir"
      fi

      cd $subdir; build_push ${IMAGE} ${TAG}
    )
done
