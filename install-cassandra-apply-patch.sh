#!/bin/bash


source ../instana.env
source ./help-functions.sh

MANIFEST_HOME=$(get_manifest_home)

MANIFEST=$MANIFEST_HOME/"cassandra-patch-${INSTANA_VERSION}.yaml"

echo applying cassandra patch $MANIFEST, namespace instana-cassandra

if test ! -f $MANIFEST; then
   echo manifest $MANIFEST not found
   exit 1
fi

$KUBECTL apply -f $MANIFEST -n instana-cassandra
