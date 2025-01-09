#!/bin/bash

source ../instana.env

source ./help-functions.sh

INSTALL_HOME=$(get_install_home)
MIRROR_HOME=$(get_mirror_home)

mkdir -p $MIRROR_HOME

echo writing backend image list to ${MIRROR_HOME}/${INSTANA_BACKEND_IMAGE_LIST_FILE}

set -x

if test "$INSTANA_VERSION" = "287"
then
${INSTALL_HOME}/bin/kubectl-instana versions list-images --instana-version $INSTANA_VERSION > ${MIRROR_HOME}/${INSTANA_BACKEND_IMAGE_LIST_FILE}

elif test "$INSTANA_VERSION" = "278"
then
${INSTALL_HOME}/bin/kubectl-instana images > ${MIRROR_HOME}/${INSTANA_BACKEND_IMAGE_LIST_FILE}

else
echo Set INSTANA_VERSION variable to supported version, current value ${INSTANA_VERSION:"undefined"}
exit 1
fi

