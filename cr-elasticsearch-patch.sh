#!/bin/bash

INSTANA_VERSION_OVERRIDE=$2

source ../instana.env
source ./help-functions.sh
source ./datastore-images.env

OUT_DIR=$(get_make_manifest_home)
MANIFEST="$OUT_DIR/elasticsearch-patch-${INSTANA_VERSION}.yaml"

replace_manifest=${1:-"noreplace"}

check_replace_manifest $MANIFEST $replace_manifest

echo writing elasticsearch patch to $MANIFEST

cat <<EOF > $MANIFEST
spec:
  version: ${ELASTICSEARCH_VERSION}
  image: ${PRIVATE_REGISTRY}/${ELASTICSEARCH_IMG}
EOF
