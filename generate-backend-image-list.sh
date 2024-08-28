#!/bin/bash

source ../instana.env

source ./help-functions.sh

INSTALL_HOME=$(get_install_home)
MIRROR_HOME=$(get_mirror_home)

mkdir -p $MIRROR_HOME

echo writing backend image list to ${MIRROR_HOME}/${INSTANA_BACKEND_IMAGE_LIST_FILE}

${INSTALL_HOME}/bin/kubectl-instana images > ${MIRROR_HOME}/${INSTANA_BACKEND_IMAGE_LIST_FILE}
