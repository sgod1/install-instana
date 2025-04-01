#!/bin/bash

source ../instana.env
source ./help-functions.sh
source ./release.env

OUT_DIR=$(get_make_manifest_home)
MANIFEST="$OUT_DIR/core-patch-${INSTANA_VERSION}.yaml"

replace_manifest=${1:-"noreplace"}

check_replace_manifest $MANIFEST $replace_manifest

echo writing core patch to $MANIFEST

cat <<EOF > $MANIFEST
[
   {"op":"replace","path": "/spec/imageConfig/registry", "value":"${PRIVATE_REGISTRY}"},
   {"op":"replace","path": "/spec/imageConfig/tag", "value":"${__instana_sem_version["${INSTANA_VERSION}"]}"},
]
EOF
