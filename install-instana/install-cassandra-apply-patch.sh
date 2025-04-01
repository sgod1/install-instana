#!/bin/bash


source ../instana.env
source ./help-functions.sh

MANIFEST_HOME=$(get_manifest_home)

MANIFEST=$MANIFEST_HOME/"cassandra-patch-${INSTANA_VERSION}.yaml"

SNAPSHOT_HOME=$(get_make_snapshot_home)

SNAPSHOT=${SNAPSHOT_HOME}/cassandra-$(snapshot_name $INSTANA_VERSION).yaml

echo applying cassandra patch $MANIFEST, namespace instana-cassandra

if test ! -f $MANIFEST; then
   echo manifest $MANIFEST not found
   exit 1
fi

# take snapshot
$KUBECTL get CassandraDatacenter/cassandra -n instana-cassandra -o yaml > ${SNAPSHOT}

# apply patch
$KUBECTL patch CassandraDatacenter/cassandra --type json --patch-file ${MANIFEST} -n instana-cassandra
