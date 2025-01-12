#!/bin/bash

INSTANA_VERSION_OVERRIDE=$2

source ../instana.env
source ./help-functions.sh
source ./datastore-images.env

OUT_DIR=$(get_make_manifest_home)
MANIFEST="$OUT_DIR/zookeeper-patch-${INSTANA_VERSION}.yaml"

replace_manifest=${1:-"noreplace"}

check_replace_manifest $MANIFEST $replace_manifest

echo writing zookeeper patch to $MANIFEST

cat <<EOF > $MANIFEST
spec:
  kafka:
    image: ${PRIVATE_REGISTRY}/${KAFKA_IMG}

  entityOperator:
    userOperator:
      image: ${PRIVATE_REGISTRY}/${KAFKA_OPERATOR_IMG}
EOF
