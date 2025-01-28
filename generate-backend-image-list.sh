#!/bin/bash

source ../instana.env
source ./release.env

source ./help-functions.sh

INSTALL_HOME=$(get_install_home)

MIRROR_HOME=$(get_mirror_home)
MIRROR_HOME=${MIRROR_HOME}/${INSTANA_VERSION}

mkdir -p $MIRROR_HOME

echo writing backend image list to ${MIRROR_HOME}/${INSTANA_BACKEND_IMAGE_LIST_FILE}, Instana version: $INSTANA_VERSION

set -x

# instana semantic version
semver=${__instana_sem_version[${INSTANA_VERSION}]}

${INSTALL_HOME}/bin/kubectl-instana versions list-images --download-key="$DOWNLOAD_KEY" --instana-version "$semver" > ${MIRROR_HOME}/${INSTANA_BACKEND_IMAGE_LIST_FILE}_1

IMG_PLATFORM=${PODMAN_IMG_PLATFORM:-"--platform linux/amd64"}

awk '{print "--platform linux/amd64 " $0}' ${MIRROR_HOME}/${INSTANA_BACKEND_IMAGE_LIST_FILE}_1 > ${MIRROR_HOME}/${INSTANA_BACKEND_IMAGE_LIST_FILE}
