#!/bin/bash

source ../instana.env
source ./install.env
source ./datastore-images.env
source ./help-functions.sh
source ./cr-env.sh

replace_manifest=${1:-"noreplace"}

export zookeeper_image_name=`echo ${ZOOKEEPER_IMG} | cut -d : -f 1 -`
export zookeeper_image_repository=${PRIVATE_REGISTRY}/${zookeeper_image_name}
export zookeeper_image_tag=`echo ${ZOOKEEPER_IMG} | cut -d : -f 2 -`

export rwo_storageclass=${RWO_STORAGECLASS}

template_cr=$CR_TEMPLATE_FILENAME_ZOOKEEPER
env_file=$CR_ENV_FILENAME_ZOOKEEPER
profile=${INSTANA_INSTALL_PROFILE}

OUT_DIR=$(get_make_manifest_home)

MANIFEST=$(format_file_path $OUT_DIR $MANIFEST_FILENAME_ZOOKEEPER $profile $INSTANA_VERSION)

check_replace_manifest $MANIFEST $replace_manifest
copy_template_manifest $template_cr $MANIFEST $profile

cr_env $template_cr $env_file $MANIFEST $profile
check_return_code $?

# post gen update, delete pod security context for ocp
# yq -i 'del(.spec.pod.securityContext)' $MANIFEST

echo updated zookeeper manifest $MANIFEST, profile $profile
