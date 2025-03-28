#!/bin/bash

source ../instana.env
source ./help-functions.sh

MANIFEST_HOME=$(get_manifest_home)

MANIFEST=$MANIFEST_HOME/zookeeper-patch-${INSTANA_VERSION}.yaml

SNAPSHOT_HOME=$(get_make_snapshot_home)

SNAPSHOT=${SNAPSHOT_HOME}/zookeeper-$(snapshot_name $INSTANA_VERSION).yaml

echo applying zookeeper patch $MANIFEST, namespace instana-clickhouse

if test ! -f $MANIFEST; then
   echo manifest $MANIFEST not found
   exit 1
fi

set -x

# take snapshot
$KUBECTL get ZookeeperCluster/instana-zookeeper -n instana-clickhouse -o yaml > ${SNAPSHOT}

# apply patch
$KUBECTL patch ZookeeperCluster/instana-zookeeper --type json --patch-file ${MANIFEST} -n instana-clickhouse
