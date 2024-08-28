#!/bin/bash

source ../instana.env
source ./help-functions.sh

MANIFEST_HOME=$(get_manifest_home)

MANIFEST=$MANIFEST_HOME/$MANIFEST_FILENAME_ELASTICSEARCH

echo applying elasticsearch cr $MANIFEST, namespace instana-elasticsearch

if test ! -f $MANIFEST; then
   echo manifest $MANIFEST not found
   exit 1
fi

$KUBECTL apply -f $MANIFEST -n instana-elasticsearch

