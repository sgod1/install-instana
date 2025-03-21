#!/bin/bash

source ../instana.env
source ./plugin.env

source ./help-functions.sh

INSTALL_HOME=$(get_make_install_home)
BIN_DIR=$(get_make_bin_home)

function cleanup_plugin_tar() {
   local plugin_tar=$1

   if test -f $BIN_DIR/${plugin_tar}; then
      rm $BIN_DIR/${plugin_tar}
   fi
}

__imglist=""

function build_img_list() {
   local plugin_tar=$1
   local plugin_url=$2
   if test ! -f $BIN_DIR/${plugin_tar}; then
      __imglist="$__imglist $plugin_url"
   fi
}

#
# main
#

reload=${1:-"noreload"}

if test $reload = "reload"; then
cleanup_plugin_tar ${INSTANA_PLUGIN_TAR_LINUX_AMD64}
cleanup_plugin_tar ${INSTANA_PLUGIN_TAR_LINUX_ARM64}
cleanup_plugin_tar ${INSTANA_PLUGIN_TAR_DARWIN_AMD64}
cleanup_plugin_tar ${INSTANA_PLUGIN_TAR_DARWIN_ARM64}
fi

build_img_list ${INSTANA_PLUGIN_TAR_LINUX_AMD64} ${INSTANA_PLUGIN_URL_LINUX_AMD64}
build_img_list ${INSTANA_PLUGIN_TAR_LINUX_ARM64} ${INSTANA_PLUGIN_URL_LINUX_ARM64}
build_img_list ${INSTANA_PLUGIN_TAR_DARWIN_AMD64} ${INSTANA_PLUGIN_URL_DARWIN_AMD64}
build_img_list ${INSTANA_PLUGIN_TAR_DARWIN_ARM64} ${INSTANA_PLUGIN_URL_DARWIN_ARM64}

set -x

if test "$__imglist"; then
wget -w 3 --user=_ --password=${DOWNLOAD_KEY} -P ${BIN_DIR} $__imglist
else
echo instana plugin already downloaded to $BIN_DIR ...
fi
