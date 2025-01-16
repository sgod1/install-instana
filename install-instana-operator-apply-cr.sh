#!/bin/bash

source ../instana.env
source ./help-functions.sh

INSTALL_HOME=$(get_install_home)
BIN_HOME=$(get_bin_home)

MANIFEST_DIR=$INSTALL_HOME/instana-operator-manifests

MANIFEST_DIR=$MANIFEST_DIR/"${INSTANA_PLUGIN_VERSION}-${INSTANA_PLUGIN}"

if test ! -d $MANIFEST_DIR; then
   echo Instsana operator manifest directory $MANIFEST_DIR not found
   exit 1
fi

echo ""
echo "applying Instana operator manifest directory $MANIFEST_DIR"
echo ""

set -x
$KUBECTL apply -f $MANIFEST_DIR
