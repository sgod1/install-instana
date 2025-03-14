#!/bin/bash

source ../instana.env
source ./datastore-images.env
source ./help-functions.sh
source ./cr-env.sh

replace_manifest=${1:-"noreplace"}

export zookeeper_image_name=`echo ${ZOOKEEPER_IMG} | cut -d : -f 1 -`
export zookeeper_image_repository=${PRIVATE_REGISTRY}/${zookeeper_image_name}
export zookeeper_image_tag=`echo ${ZOOKEEPER_IMG} | cut -d : -f 2 -`

export rwo_storageclass=${RWO_STORAGECLASS}

template_cr="zookeeper-template.yaml"
env_file="zookeeper-env.yaml"
profile=${INSTANA_INSTALL_PROFILE:-"template"}

OUT_DIR=$(get_make_manifest_home)
MANIFEST="${OUT_DIR}/zookeeper-env-${INSTANA_VERSION}.yaml"

check_replace_manifest $MANIFEST $replace_manifest
copy_template_manifest $template_cr $MANIFEST $profile

cr_env $template_cr $env_file $MANIFEST $profile

# post gen update, delete pod security context for ocp
# yq -i 'del(.spec.pod.securityContext)' $MANIFEST

echo updated zookeeper manifest $MANIFEST, profile $profile
