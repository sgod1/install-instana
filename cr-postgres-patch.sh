#!/bin/bash

source ../instana.env
source ./help-functions.sh
source ./datastore-images.env

OUT_DIR=$(get_make_manifest_home)
MANIFEST="$OUT_DIR/postgres-patch-${INSTANA_VERSION}.yaml"

replace_manifest=${1:-"noreplace"}

check_replace_manifest $MANIFEST $replace_manifest

echo writing postgres patch to $MANIFEST

cat <<EOF > $MANIFEST
spec:
  imageName: ${PRIVATE_REGISTRY}/${POSTGRES_IMG}
EOF
