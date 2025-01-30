#!/bin/bash

source ../instana.env
source ./help-functions.sh
source ./datastore-images.env

OUT_DIR=$(get_make_manifest_home)

MANIFEST="${OUT_DIR}/cassandra-patch-${INSTANA_VERSION}.yaml"

replace_manifest=${1:-"noreplace"}

check_replace_manifest $MANIFEST $replace_manifest

echo writing cassandra patch to $MANIFEST

cat <<EOF > $MANIFEST
[
   {"op":"replace", "path":"/spec/serverImage", "value":"${PRIVATE_REGISTRY}/${CASSANDRA_IMG}"},
   {"op":"replace", "path":"/spec/systemLoggerImage", "value":"${PRIVATE_REGISTRY}/${CASSANDRA_SYSTEM_LOGGER_IMG}"},
   {"op":"replace", "path":"/spec/k8ssandraClientImage", "value":"${PRIVATE_REGISTRY}/${CASSANDRA_K8S_CLIENT_IMG}"},
]
EOF
