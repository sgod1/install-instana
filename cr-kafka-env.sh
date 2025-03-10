#!/bin/bash

source ../instana.env
source ./datastore-images.env
source ./help-functions.sh
source ./cr-env.sh

replace_manifest=${1:-"noreplace"}

template_cr="kafka-template.yaml"
env_file="kafka-env.yaml"
profile=${INSTANA_INSTALL_PROFILE:-"template"}

OUT_DIR=$(get_make_manifest_home)
MANIFEST="${OUT_DIR}/kafka-env-${INSTANA_VERSION}.yaml"

check_replace_manifest $MANIFEST $replace_manifest
cp $template_cr $MANIFEST

cr_env $template_cr $env_file $MANIFEST $profile

echo updated kafka manifest $MANIFEST
