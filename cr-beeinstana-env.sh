#!/bin/bash

source ../instana.env
source ./datastore-images.env
source ./help-functions.sh
source ./cr-env.sh

replace_manifest=${1:-"noreplace"}

export beeinstana_image_registry=${PRIVATE_REGISTRY}
export beeinstana_ingestor_img_tag=`echo ${BEEINSTANA_INGESTOR_IMG} | cut -d : -f 2 -`
export beeinstana_aggregator_img_tag=`echo ${BEEINSTANA_AGGREGATOR_IMG} | cut -d : -f 2 -`
export beeinstana_monconfig_img_tag=`echo ${BEEINSTANA_MONCONFIG_IMG} | cut -d : -f 2 -`

export rwo_storageclass=${RWO_STORAGECLASS}

template_cr="beeinstana-template.yaml"
env_file="beeinstana-env.yaml"
profile=${INSTANA_INSTALL_PROFILE:-"template"}

OUT_DIR=$(get_make_manifest_home)
MANIFEST="${OUT_DIR}/beeinstana-env-${INSTANA_VERSION}.yaml"

check_replace_manifest $MANIFEST $replace_manifest
cp $template_cr $MANIFEST

cr_env $template_cr $env_file $MANIFEST $profile

echo updated beeinstana manifest $MANIFEST
