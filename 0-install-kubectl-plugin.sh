#!/bin/bash

source ../instana.env
source ./release.env

source ./help-functions.sh

INSTALL_HOME=$(get_make_install_home)
BIN_DIR=$(get_make_bin_home)

echo "
INSTANA_VERSION=$INSTANA_VERSION
INSTANA_PLUGIN_RELEASE=$INSTANA_PLUGIN_RELEASE
" > ${INSTALL_HOME}/release.env

machine=`uname -m`
os=`uname -o`

echo uname: `uname -a`
echo machine: $machine, os: $os

plugin_tar=""

if compare_values $os "Darwin"; then
   if compare_values $machine "x86_64"; then
      plugin_tar=${INSTANA_PLUGIN_TAR_DARWIN_AMD64}
   else
      plugin_tar=${INSTANA_PLUGIN_TAR_DARWIN_ARM64}
   fi
else
   if compare_values $machine "x86_64"; then
      plugin_tar=${INSTANA_PLUGIN_TAR_LINUX_AMD64}
   else
      plugin_tar=${INSTANA_PLUGIN_TAR_LINUX_ARM64}
   fi
fi

if test -z $plugin_tar; then
   echo instana plugin tar name undefined, uname: `uname -a`
   exit 1
fi

if test ! -f $BIN_DIR/$plugin_tar; then
   echo instana plugin tar file $BIN_DIR/$plugin_tar not found
   exit 1
fi

echo ""
echo installing kubectl-instana plugin $plugin_tar to $BIN_DIR
echo ""

if test -f $BIN_DIR/kubectl-instana; then rm $BIN_DIR/kubectl-instana; fi
tar xvf $BIN_DIR/${plugin_tar} -C $BIN_DIR
