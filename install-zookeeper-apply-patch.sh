#!/bin/bash

INSTANA_VERSION_OVERRIDE=$1

source ../instana.env
source ./help-functions.sh

MANIFEST_HOME=$(get_manifest_home)

MANIFEST=$MANIFEST_HOME/zookeeper-patch-${INSTANA_VERSION}.yaml

echo applying zookeeper patch $MANIFEST, namespace instana-clickhouse

if test ! -f $MANIFEST; then
   echo manifest $MANIFEST not found
   exit 1
fi

set -x

$KUBECTL patch ZookeeperCluster/instana-zookeeper --type merge --patch-file ${MANIFEST} -n instana-clickhouse
