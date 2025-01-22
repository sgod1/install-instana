#!/bin/bash

source ../instana.env
source ./help-functions.sh

MANIFEST_HOME=$(get_manifest_home)

MANIFEST=$MANIFEST_HOME/kafka-patch-${INSTANA_VERSION}.yaml

SNAPSHOT_HOME=$(get_make_snapshot_home)

SNAPSHOT=${SNAPSHOT_HOME}/kafka-$(snapshot_name $INSTANA_VERSION).yaml

echo applying kafka patch $MANIFEST, namespace instana-kafka

if test ! -f $MANIFEST; then
   echo manifest $MANIFEST not found
   exit 1
fi

set -x

# take snapshot
$KUBECTL get Kafka/instana -n instana-kafka -o yaml > ${SNAPSHOT}

# apply patch
$KUBECTL patch Kafka/instana --type merge --patch-file ${MANIFEST} -n instana-kafka
