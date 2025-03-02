#!/bin/bash

source ../instana.env
source ./help-functions.sh

ARTIFACT_PUBLIC="artifact-public.instana.io"

BIN_HOME=$(get_bin_home)

MIRROR_HOME=$(get_make_mirror_home)
MIRROR_HOME=${MIRROR_HOME}/${INSTANA_VERSION}
mkdir -p ${MIRROR_HOME}

OUTFILE="${MIRROR_HOME}/${INSTANA_OPERATOR_IMAGE_LIST_FILE}"

IMG_PLATFORM=${PODMAN_IMG_PLATFORM:-"--platform linux/amd64"}

echo writing instana operator image list to ${OUTFILE}

echo "# Instana operator images, Instana version: $INSTANA_VERSION" > ${OUTFILE}

# instana operator image is linked to plugin version
plugin_version=`${BIN_HOME}/kubectl-instana -v | cut -d " " -f3`

INSTANA_OPERATOR_IMAGE=infrastructure/instana-enterprise-operator:${plugin_version}

echo "${IMG_PLATFORM} ${ARTIFACT_PUBLIC}/${INSTANA_OPERATOR_IMAGE}" >> ${OUTFILE}
