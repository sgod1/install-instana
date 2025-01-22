#!/bin/bash

source ../instana.env
source ./help-functions.sh

MANIFEST_HOME=$(get_manifest_home)

MANIFEST=$MANIFEST_HOME/clickhouse-patch-${INSTANA_VERSION}.yaml

SNAPSHOT_HOME=$(get_make_snapshot_home)

SNAPSHOT=${SNAPSHOT_HOME}/clickhouse-$(snapshot_name $INSTANA_VERSION).yaml

echo applying clickhouse patch $MANIFEST, namespace instana-clickhouse

if test ! -f $MANIFEST; then
   echo manifest $MANIFEST not found
   exit 1
fi

set -x

# take snapshot
$KUBECTL get chi/instana -n instana-clickhouse -n instana-clickhouse -o yaml > ${SNAPSHOT}

# apply patch
$KUBECTL patch chi/instana --type merge --patch-file ${MANIFEST} -n instana-clickhouse
