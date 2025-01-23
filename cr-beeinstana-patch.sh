#!/bin/bash

source ../instana.env
source ./help-functions.sh
source ./datastore-images.env

OUT_DIR=$(get_make_manifest_home)

MANIFEST="$OUT_DIR/beeinstana-patch-${INSTANA_VERSION}.yaml"

replace_manifest=${1:-"no_replace"}

check_replace_manifest $MANIFEST $replace_manifest

echo writing beeinstana patch to $MANIFEST

beeinstana_monconfig_img_repo=`echo ${BEEINSTANA_MONCONFIG_IMG} | cut -d : -f 1 -`
beeinstana_monconfig_img_tag=`echo ${BEEINSTANA_MONCONFIG_IMG} | cut -d : -f 2 -`

beeinstana_ingestor_img_repo=`echo ${BEEINSTANA_INGESTOR_IMG} | cut -d : -f 1 -`
beeinstana_ingestor_img_tag=`echo ${BEEINSTANA_INGESTOR_IMG} | cut -d : -f 2 -`

beeinstana_aggregator_img_repo=`echo ${BEEINSTANA_AGGREGATOR_IMG} | cut -d : -f 1 -`
beeinstana_aggregator_img_tag=`echo ${BEEINSTANA_AGGREGATOR_IMG} | cut -d : -f 2 -`

cat << EOF > $MANIFEST
[
   {"op":"replace", "path":"/spec/config/image/name", "value":"${beeinstana_monconfig_img_repo}"},
   {"op":"replace", "path":"/spec/config/image/tag", "value":"${beeinstana_monconfig_img_tag}"},
   {"op":"replace", "path":"/spec/ingestor/image/name", "value":"${beeinstana_ingestor_img_repo}"},
   {"op":"replace", "path":"/spec/ingestor/image/tag", "value":"${beeinstana_ingestor_img_tag}"},
   {"op":"replace", "path":"/spec/aggregator/image/name", "value":"${beeinstana_aggregator_img_repo}"},
   {"op":"replace", "path":"/spec/aggregator/image/tag", "value":"${beeinstana_aggregator_img_tag}"},
]
EOF
