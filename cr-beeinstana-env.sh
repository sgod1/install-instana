#!/bin/bash

source ../instana.env
source ./install.env
source ./datastore-images.env
source ./help-functions.sh
source ./cr-env.sh

replace_manifest=${1:-"noreplace"}

export beeinstana_image_registry=${PRIVATE_REGISTRY}
export beeinstana_ingestor_img_tag=`echo ${BEEINSTANA_INGESTOR_IMG} | cut -d : -f 2 -`
export beeinstana_aggregator_img_tag=`echo ${BEEINSTANA_AGGREGATOR_IMG} | cut -d : -f 2 -`
export beeinstana_monconfig_img_tag=`echo ${BEEINSTANA_MONCONFIG_IMG} | cut -d : -f 2 -`

export rwo_storageclass=${RWO_STORAGECLASS}

template_cr=$CR_TEMPLATE_FILENAME_BEEINSTANA
env_file=$CR_ENV_FILENAME_BEEINSTANA
profile=${INSTANA_INSTALL_PROFILE}

OUT_DIR=$(get_make_manifest_home)

MANIFEST=$(format_file_path $OUT_DIR $MANIFEST_FILENAME_BEEINSTANA $profile $INSTANA_VERSION)

check_replace_manifest $MANIFEST $replace_manifest
copy_template_manifest $template_cr $MANIFEST $profile

cr_env $template_cr $env_file $MANIFEST $profile
check_return_code $?

echo updated beeinstana manifest $MANIFEST, profile $profile
