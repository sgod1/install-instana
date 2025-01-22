#!/bin/bash

source ../instana.env
source ./help-functions.sh

MANIFEST_HOME=$(get_manifest_home)

MANIFEST=$MANIFEST_HOME/elasticsearch-patch-${INSTANA_VERSION}.yaml

SNAPSHOT_HOME=$(get_make_snapshot_home)

SNAPSHOT=${SNAPSHOT_HOME}/elasticsearch-$(snapshot_name $INSTANA_VERSION).yaml

echo applying elasticsearch patch $MANIFEST, namespace instana-elasticsearch

if test ! -f $MANIFEST; then
   echo manifest $MANIFEST not found
   exit 1
fi

set -x

# take snapshot
$KUBECTL get Elasticsearch/instana -n instana-elasticsearch -o yaml > ${SNAPSHOT}

# apply patch
$KUBECTL patch Elasticsearch/instana --type merge --patch-file ${MANIFEST} -n instana-elasticsearch
