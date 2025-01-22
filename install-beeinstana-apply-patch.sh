#!/bin/bash

source ../instana.env
source ./help-functions.sh

MANIFEST_HOME=$(get_manifest_home)

MANIFEST=$MANIFEST_HOME/"beeinstana-patch-${INSTANA_VERSION}.yaml"

echo applying beeinstana patch $MANIFEST, namespace beeinstana

if test ! -f $MANIFEST; then
   echo manifest $MANIFEST not found
   exit 1
fi

${KUBECTL} -n beeinstana apply -f $MANIFEST
