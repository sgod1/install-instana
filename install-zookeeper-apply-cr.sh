#!/bin/bash

source ../instana.env
source ./help-functions.sh

MANIFEST_HOME=$(get_manifest_home)

MANIFEST=$MANIFEST_HOME/$MANIFEST_FILENAME_ZOOKEEPER

echo applying zookeeper cr $MANIFEST, namespace instana-clickhouse

if test ! -f $MANIFEST; then
   echo manifest $MANIFEST not found
   exit 1
fi

$KUBECTL apply -f $MANIFEST -n instana-clickhouse

