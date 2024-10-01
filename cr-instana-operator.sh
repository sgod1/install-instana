#!/bin/bash

source ../instana.env
source ./help-functions.sh

INSTALL_HOME=$(get_install_home)
BIN_HOME=$(get_bin_home)

INSTANA_KUBECTL=$BIN_HOME/kubectl-instana

if test ! -f $INSTANA_KUBECTL; then
   echo Instana plugin $INSTANA_KUBECTL not found
   exit 1
fi

MANIFEST_DIR=$INSTALL_HOME/instana-operator-manifests

replace_manifest_dir=${1:-"noreplace"}

check_replace_manifest_dir $MANIFEST_DIR $replace_manifest_dir

#
# generate manifests
#
if test -d $MANIFEST_DIR; then
   rm -r $MANIFEST_DIR
fi

mkdir -p $MANIFEST_DIR

echo ""
echo Generating Instana operator manifests in $MANIFEST_DIR directory
echo ""

set -x
$INSTANA_KUBECTL operator template --output-dir $MANIFEST_DIR
