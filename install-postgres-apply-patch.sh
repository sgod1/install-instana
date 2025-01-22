#!/bin/bash

source ../instana.env
source ./help-functions.sh

MANIFEST_HOME=$(get_manifest_home)

MANIFEST=$MANIFEST_HOME/postgres-patch-${INSTANA_VERSION}.yaml

SNAPSHOT_HOME=$(get_make_snapshot_home)

SNAPSHOT=${SNAPSHOT_HOME}/postgres-$(snapshot_name $INSTANA_VERSION).yaml

echo applying postgres patch $MANIFEST, namespace instana-postgres

if test ! -f $MANIFEST; then
   echo manifest $MANIFEST not found
   exit 1
fi

set -x

# take snapshot
$KUBECTL get cluster/postgres -n instana-postgres -n instana-postgres -o yaml > ${SNAPSHOT}

# apply patch
$KUBECTL patch cluster/postgres --type merge --patch-file ${MANIFEST} -n instana-postgres
