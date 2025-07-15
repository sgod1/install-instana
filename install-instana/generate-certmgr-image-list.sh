#!/bin/bash

source ../instana.env
source ./release.env
source ./install.env
source ./help-functions.sh
source ./certmgr-images.env

ARTIFACT_PUBLIC="artifact-public.instana.io"

MIRROR_HOME=$(get_make_mirror_home)
MIRROR_HOME=${MIRROR_HOME}/${INSTANA_VERSION}
mkdir -p ${MIRROR_HOME}

OUTFILE="${MIRROR_HOME}/${CERT_MGR_IMAGE_LIST_FILE}"

# instana semantic version
semver=${__instana_sem_version[${INSTANA_VERSION}]}

echo writing cert manager image list to ${OUTFILE}, instana version $semver

echo "# Certmgr images, Instana version: $semver" > ${OUTFILE}

for img in ${__certmgr_image_list[@]}
do
   echo "${ARTIFACT_PUBLIC}/${img}" >> ${OUTFILE}
done
