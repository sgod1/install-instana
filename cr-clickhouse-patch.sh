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
[
   {"op":"replace","path": "/spec/templates/podTemplates/0/spec/containers/0/image", "value":"${PRIVATE_REGISTRY}/${CLICKHOUSE_OPENSSL_IMG}"},
   {"op":"replace","path": "/spec/templates/podTemplates/0/spec/containers/1/image", "value":"${PRIVATE_REGISTRY}/${CLICKHOUSE_OPENSSL_IMG}"},
EOF

if test "${INSTANA_PLUGIN_VERSION}" = "1.2.0"; then
cat <<EOF >> $MANIFEST
   {"op":"add", "path":"/spec/configuration/profiles/default~1allow_experimental_analyzer", "value":"0"},
EOF
fi
cat <<EOF >> $MANIFEST
]
EOF

