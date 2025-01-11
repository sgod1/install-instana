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

zookeeper_img_repo=`echo ${ZOOKEEPER_IMG} | cut -d : -f 1 -`
zookeeper_img_tag=`echo ${ZOOKEEPER_IMG} | cut -d : -f 2 -`

cat <<EOF > $MANIFEST
spec:
  image:
    repository: ${PRIVATE_REGISTRY}/${zookeeper_img_repo}
    tag: ${zookeeper_img_tag}
EOF

# oc patch ZookeeperCluster/instana-zookeeper --type merge --patch-file ./gen/zookeeper-patch-287.json
