#!/bin/bash

source ../instana.env
source ./help-functions.sh
source ./datastore-images.env

OUT_DIR=$(get_make_manifest_home)

MANIFEST="${OUT_DIR}/cassandra-patch-${INSTANA_VERSION}.yaml"

replace_manifest=${1:-"noreplace"}

check_replace_manifest $MANIFEST $replace_manifest

echo writing cassandra patch to $MANIFEST

cat << EOF > $MANIFEST
apiVersion: cassandra.datastax.com/v1beta1
kind: CassandraDatacenter
metadata:
  name: cassandra
spec:
  serverImage: $PRIVATE_REGISTRY/$CASSANDRA_IMG
  systemLoggerImage: $PRIVATE_REGISTRY/$CASSANDRA_SYSTEM_LOGGER_IMG
  k8ssandraClientImage: $PRIVATE_REGISTRY/$CASSANDRA_K8S_CLIENT_IMG
EOF
