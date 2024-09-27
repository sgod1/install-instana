#!/bin/bash

source ./release.env
source ../instana.env

source ./help-functions.sh

INSTALL_HOME=$(get_make_install_home)
BIN_DIR=$(get_make_bin_home)

function cleanup_plugin_tar() {
   plugin_tar=$1

   if test -f $BIN_DIR/${plugin_tar}; then
      rm $BIN_DIR/${plugin_tar}
   fi
}

cleanup_plugin_tar ${INSTANA_PLUGIN_TAR_LINUX_AMD64}
cleanup_plugin_tar ${INSTANA_PLUGIN_TAR_LINUX_ARM64}
cleanup_plugin_tar ${INSTANA_PLUGIN_TAR_DARWIN_AMD64}
cleanup_plugin_tar ${INSTANA_PLUGIN_TAR_DARWIN_ARM64}

set -x

wget -w 3 --user=_ --password=${DOWNLOAD_KEY} -P ${BIN_DIR}  ${INSTANA_PLUGIN_URL_LINUX_AMD64} ${INSTANA_PLUGIN_URL_LINUX_ARM64} ${INSTANA_PLUGIN_URL_DARWIN_AMD64} ${INSTANA_PLUGIN_URL_DARWIN_ARM64}
