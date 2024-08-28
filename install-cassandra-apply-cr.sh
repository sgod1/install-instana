#!/bin/bash


source ../instana.env
source ./help-functions.sh

MANIFEST_HOME=$(get_manifest_home)

MANIFEST=$MANIFEST_HOME/$MANIFEST_FILENAME_CASSANDRA

echo applying cassandra cr $MANIFEST, namespace instana-cassandra

if test ! -f $MANIFEST; then
   echo manifest $MANIFEST not found
   exit 1
fi

$KUBECTL apply -f $MANIFEST -n instana-cassandra
