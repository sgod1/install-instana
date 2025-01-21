#!/bin/bash

source ../instana.env
source ./help-functions.sh

source ./certmgr-images.env

ARTIFACT_PUBLIC="artifact-public.instana.io"

MIRROR_HOME=$(get_make_mirror_home)
MIRROR_HOME=${MIRROR_HOME}/${INSTANA_VERSION}

OUTFILE="${MIRROR_HOME}/${CERT_MGR_IMAGE_LIST_FILE}"

echo writing cert manager image list to ${OUTFILE}

echo "# Certmgr images, Instana version: $INSTANA_VERSION" > ${OUTFILE}

for img in ${__certmgr_image_list[@]}
do
   echo "${CERTMGR_IMG_PLATFORM} ${ARTIFACT_PUBLIC}/${img}" >> ${OUTFILE}
done
