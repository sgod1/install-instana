#!/bin/bash

source ../instana.env
source ./help-functions.sh

MANIFEST_HOME=$(get_manifest_home)

MANIFEST=$MANIFEST_HOME/core-patch-${INSTANA_VERSION}.yaml

SNAPSHOT_HOME=$(get_make_snapshot_home)

SNAPSHOT=${SNAPSHOT_HOME}/core-$(snapshot_name $INSTANA_VERSION).yaml

echo applying core patch $MANIFEST, namespace instana-core

if test ! -f $MANIFEST; then
   echo manifest $MANIFEST not found
   exit 1
fi

set -x

# take snapshot
$KUBECTL get core/instana-core -n instana-core -o yaml > ${SNAPSHOT}

# apply patch
$KUBECTL patch core/instana-core --type json --patch-file ${MANIFEST} -n instana-core
