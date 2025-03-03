#!/bin/bash

source ./help-functions.sh

INSTALL_HOME=$(get_make_install_home)
BIN_HOME=$(get_make_bin_home)

function cleanup_tool_tar() {
   tool_tar=$1

   if test -f $BIN_HOME/${tool_tar}; then
      rm $BIN_HOME/${tool_tar}
   fi
}

#
# yq
#
YQ_TAR_LINUX_AMD64=yq_linux_amd64.tar.gz
YQ_TAR_LINUX_ARM64=yq_linux_arm64.tar.gz
YQ_TAR_DARWIN_AMD64=yq_darwin_arm64.tar.gz
YQ_TAR_DARWIN_ARM64=yq_darwin_amd64.tar.gz

YQ_URL=https://github.com/mikefarah/yq/releases/latest/download

cleanup_tool_tar $YQ_TAR_LINUX_AMD64
cleanup_tool_tar $YQ_TAR_LINUX_ARM64
cleanup_tool_tar $YQ_TAR_DARWIN_AMD64
cleanup_tool_tar $YQ_TAR_DARWIN_ARM64

wget -w 3 -P ${BIN_HOME} \
	${YQ_URL}/${YQ_TAR_LINUX_AMD64} \
	${YQ_URL}/${YQ_TAR_LINUX_ARM64} \
	${YQ_URL}/${YQ_TAR_DARWIN_AMD64} \
	${YQ_URL}/${YQ_TAR_DARWIN_ARM64}
