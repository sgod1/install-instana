#!/bin/bash

source ../instana.env
source ./datastore-images.env
source ./help-functions.sh
source ./cr-env.sh

replace_manifest=${1:-"noreplace"}

template_cr="zookeeper-template.yaml"
env_file="zookeeper-env.yaml"
out_file="gen/zookeeper-env-289.yaml"
profile=${INSTANA_INSTALL_PROFILE:-"template"}

OUT_DIR=$(get_make_manifest_home)
MANIFEST="${OUT_DIR}/zookeeper-env-${INSTANA_VERSION}.yaml"

check_replace_manifest $MANIFEST $replace_manifest
cp $template_cr $MANIFEST

cr_env $template_cr $env_file $MANIFEST $profile

echo updated zookeeper manifest $MANIFEST
