#!/bin/bash

source ../instana.env
source ./release.env
source ./install.env
source ./help-functions.sh
source ./gateway-images.env

ARTIFACT_PUBLIC="artifact-public.instana.io"

MIRROR_HOME=$(get_make_mirror_home)
MIRROR_HOME=${MIRROR_HOME}/${INSTANA_VERSION}
mkdir -p ${MIRROR_HOME}

OUTFILE="${MIRROR_HOME}/gateway-image-list.list"

# instana semantic version
semver=${__instana_sem_version[${INSTANA_VERSION}]}

echo writing gateway image list to ${OUTFILE}, instana version $semver

echo "# Gateway images, Instana version: $semver" > ${OUTFILE}

for img in ${__gateway_image_list[@]}
do
   echo "${ARTIFACT_PUBLIC}/${img}" >> ${OUTFILE}
done
