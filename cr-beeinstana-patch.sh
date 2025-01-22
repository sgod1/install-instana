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
apiVersion: beeinstana.instana.com/v1beta1
kind: BeeInstana
metadata:
  name: instance
  namespace: beeinstana
spec:
  config:
    image:
      name: ${beeinstana_monconfig_img_repo}
      tag: ${beeinstana_monconfig_img_tag}
  ingestor:
    image:
      name: ${beeinstana_ingestor_img_repo}
      tag: ${beeinstana_ingestor_img_tag}
  aggregator:
    image:
      name: ${beeinstana_aggregator_img_repo}
      tag: ${beeinstana_aggregator_img_tag}
EOF
