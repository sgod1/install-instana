#!/bin/bash

source ../instana.env
source ./install.env
source ./datastore-images.env
source ./help-functions.sh
source ./cr-env.sh

export PATH=".:$PATH"

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

# tolerations
tolpaths=".spec.config.tolerations .spec.ingestor.tolerations .spec.aggregator.tolerations"

export beeinstana_toleration_key=${BEEINSTANA_TOLERATION_KEY:-${TOLERATION_KEY:-"nokey"}}
export beeinstana_toleration_value=${BEEINSTANA_TOLERATION_VALUE:-${TOLERATION_VALUE:-"novalue"}}

cr-tolerations.sh $MANIFEST $beeinstana_toleration_key $beeinstana_toleration_value $tolpaths
check_return_code $?

# env
cr_env $template_cr $env_file $MANIFEST $profile
check_return_code $?

echo updated beeinstana manifest $MANIFEST, profile $profile
