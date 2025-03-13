#!/bin/bash

source ../instana.env
source ./release.env

source ./help-functions.sh
source ./install.env

INSTALL_HOME=$(get_install_home)

MIRROR_HOME=$(get_mirror_home)
MIRROR_HOME=${MIRROR_HOME}/${INSTANA_VERSION}

mkdir -p $MIRROR_HOME

outfile=${MIRROR_HOME}/${INSTANA_BACKEND_IMAGE_LIST_FILE}
echo writing backend image list to ${outfile}, Instana version: $INSTANA_VERSION

# instana semantic version
semver=${__instana_sem_version[${INSTANA_VERSION}]}

outfile_noplatform=${MIRROR_HOME}/${INSTANA_BACKEND_IMAGE_LIST_FILE}_noplatform
${INSTALL_HOME}/bin/kubectl-instana versions list-images --download-key="$DOWNLOAD_KEY" --instana-version "$semver" > $outfile_noplatform

IMG_PLATFORM=${PODMAN_IMG_PLATFORM:-"--platform linux/amd64"}

awk '{print "--platform linux/amd64 " $0}' $outfile_noplatform > $outfile

rm ${outfile_noplatform}

