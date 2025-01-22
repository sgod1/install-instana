#!/bin/bash

source ../instana.env
source ./help-functions.sh
source ./datastore-images.env

OUT_DIR=$(get_make_manifest_home)
MANIFEST="$OUT_DIR/kafka-patch-${INSTANA_VERSION}.yaml"

replace_manifest=${1:-"noreplace"}

check_replace_manifest $MANIFEST $replace_manifest

echo writing kafka patch to $MANIFEST

cat <<EOF > $MANIFEST
apiVersion: kafka.strimzi.io/v1beta2
kind: Kafka
metadata:
  name: instana
  labels:
    strimzi.io/cluster: instana
spec:
  kafka:
    image: ${PRIVATE_REGISTRY}/${KAFKA_IMG}

  entityOperator:
    userOperator:
      image: ${PRIVATE_REGISTRY}/${KAFKA_OPERATOR_IMG}
EOF
