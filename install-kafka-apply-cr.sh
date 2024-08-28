#!/bin/bash

source ../instana.env
source ./help-functions.sh

MANIFEST_HOME=$(get_manifest_home)

MANIFEST=$MANIFEST_HOME/$MANIFEST_FILENAME_KAFKA

echo applying kafka cr $MANIFEST, namespace instana-kafka

if test ! -f $MANIFEST; then
   echo manifest $MANIFEST not found
   exit 1
fi

$KUBECTL apply -f $MANIFEST -n instana-kafka
