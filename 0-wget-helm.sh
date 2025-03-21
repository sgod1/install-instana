#!/bin/bash

source ./help-functions.sh

helm_version=v3.17.2

INSTALL_HOME=$(get_make_install_home)
BIN_HOME=$(get_make_bin_home)

function cleanup_tool_tar() {
   local tool_tar=$1

   if test -f $BIN_HOME/${tool_tar}; then
      rm $BIN_HOME/${tool_tar}
   fi
}

__imglist=""

function build_img_list() {
   local plugin_tar=$1
   local plugin_url=$2
   if test ! -f $BIN_HOME/${plugin_tar}; then
      __imglist="$__imglist $plugin_url"
   fi
}

#
# main
#
reload=${1:-"noreload"}

TAR_DARWIN_AMD64="helm-${helm_version}-darwin-amd64.tar.gz"
TAR_DARWIN_ARM64="helm-${helm_version}-darwin-arm64.tar.gz"
TAR_LINUX_AMD64="helm-${helm_version}-linux-amd64.tar.gz"
TAR_LINUX_ARM64="helm-${helm_version}-linux-arm64.tar.gz"

URL="https://get.helm.sh"

if test $reload = "reload"; then
cleanup_tool_tar $TAR_LINUX_AMD64
cleanup_tool_tar $TAR_LINUX_ARM64
cleanup_tool_tar $TAR_DARWIN_AMD64
cleanup_tool_tar $TAR_DARWIN_ARM64
fi

build_img_list $TAR_LINUX_AMD64 ${URL}/${TAR_LINUX_AMD64}
build_img_list $TAR_LINUX_ARM64 ${URL}/${TAR_LINUX_ARM64}
build_img_list $TAR_DARWIN_AMD64 ${URL}/${TAR_DARWIN_AMD64}
build_img_list $TAR_DARWIN_ARM64 ${URL}/${TAR_DARWIN_ARM64}

if test "$__imglist"; then
wget -w 3 -P ${BIN_HOME} $__imglist
else
echo helm tar already downloaded to $BIN_HOME ...
fi
