#!/bin/bash

source ../instana.env
source ./install.env
source ./help-functions.sh

ARTIFACT_PUBLIC="artifact-public.instana.io"

BIN_HOME=$(get_bin_home)

MIRROR_HOME=$(get_make_mirror_home)
MIRROR_HOME=${MIRROR_HOME}/${INSTANA_VERSION}
mkdir -p ${MIRROR_HOME}

OUTFILE="${MIRROR_HOME}/${INSTANA_OPERATOR_IMAGE_LIST_FILE}"

IMG_PLATFORM=${PODMAN_IMG_PLATFORM:-"--platform linux/amd64"}

echo writing instana operator image list to ${OUTFILE}

echo "# Instana operator images, Plugin version: $INSTANA_PLUGIN_VERSION, Instana version: $INSTANA_VERSION" > ${OUTFILE}

INSTANA_OPERATOR_IMAGE=`./gen/bin/yq ".release.plugin.[] | select(.version==\"$INSTANA_PLUGIN_VERSION\") | .INSTANA_OPERATOR_IMAGE" ./$INSTANA_RELEASE_FILENAME` 
if test -z "$INSTANA_OPERATOR_IMAGE" 
   then echo "undefined plugin key: INSTANA_RELEASE_FILENAME, instana plugin version $INSTANA_PLUGIN_VERSION, file $INSTANA_RELEASE_FILENAME"
   exit 1 
fi

echo "${IMG_PLATFORM} ${ARTIFACT_PUBLIC}/${INSTANA_OPERATOR_IMAGE}" >> ${OUTFILE}
