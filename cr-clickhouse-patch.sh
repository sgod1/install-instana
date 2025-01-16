#!/bin/bash

source ../instana.env
source ./help-functions.sh
source ./datastore-images.env

OUT_DIR=$(get_make_manifest_home)
MANIFEST="$OUT_DIR/clickhouse-patch-${INSTANA_VERSION}.yaml"

replace_manifest=${1:-"noreplace"}

check_replace_manifest $MANIFEST $replace_manifest

echo writing clickhouse patch to $MANIFEST

cat <<EOF > $MANIFEST
spec:
  templates:
    podTemplates:
    - name: clickhouse
      spec:
        containers:

        - name: instana-clickhouse
          image: ${PRIVATE_REGISTRY}/${CLICKHOUSE_OPENSSL_IMG}
        - name: clickhouse-log
          image: ${PRIVATE_REGISTRY}/${CLICKHOUSE_OPENSSL_IMG}
EOF
