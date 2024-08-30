#!/bin/bash

source ../instana.env
source ./help-functions.sh

MANIFEST_HOME=$(get_manifest_home)

MANIFEST=$MANIFEST_HOME/$MANIFEST_FILENAME_CORE

if test ! -f $MANIFEST; then
   echo core manifest file $MANIFEST not found
   echo

   exit 1
fi

# apply instana-core manifest
echo applying core manifest $MANIFEST_HOME/$MANIFEST_FILENAME_CORE
echo

$KUBECTL apply -n instana-core -f $MANIFEST_HOME/$MANIFEST_FILENAME_CORE
