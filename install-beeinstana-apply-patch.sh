#!/bin/bash

source ../instana.env
source ./help-functions.sh

MANIFEST_HOME=$(get_manifest_home)

MANIFEST=$MANIFEST_HOME/"beeinstana-patch-${INSTANA_VERSION}.yaml"

SNAPSHOT_HOME=$(get_make_snapshot_home)

SNAPSHOT=${SNAPSHOT_HOME}/beeinstana-$(snapshot_name $INSTANA_VERSION).yaml

echo applying beeinstana patch $MANIFEST, namespace beeinstana

if test ! -f $MANIFEST; then
   echo manifest $MANIFEST not found
   exit 1
fi

# take snapshot
$KUBECTL get BeeInstana/instance -n beeinstana -o yaml > ${SNAPSHOT}

# apply patch
${KUBECTL} -n beeinstana apply -f $MANIFEST
