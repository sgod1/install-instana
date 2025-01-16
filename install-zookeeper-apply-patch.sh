#!/bin/bash

source ../instana.env
source ./help-functions.sh

MANIFEST_HOME=$(get_manifest_home)

MANIFEST=$MANIFEST_HOME/zookeeper-patch-${INSTANA_VERSION}.yaml

SNAPSHOT_HOME=$(get_make_snapshot_home)

SNAPSHOT=${SNAPSHOT_HOME}/zookeeper-snapshot-`date +%F-%H-%M-%S`.yaml

echo applying zookeeper patch $MANIFEST, namespace instana-clickhouse

if test ! -f $MANIFEST; then
   echo manifest $MANIFEST not found
   exit 1
fi

set -x

$KUBECTL get ZookeeperCluster/instana-zookeeper -o yaml > ${SNAPSHOT}

$KUBECTL patch ZookeeperCluster/instana-zookeeper --type merge --patch-file ${MANIFEST} -n instana-clickhouse
