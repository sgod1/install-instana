#!/bin/bash

source ../instana.env
source ./datastore-images.env
source ./help-functions.sh
source ./cr-env.sh

replace_manifest=${1:-"noreplace"}

export elasticsearch_version=${ELASTICSEARCH_VERSION}
export elasticsearch_image=$PRIVATE_REGISTRY/${ELASTICSEARCH_IMG}
export rwo_storageclass=$RWO_STORAGECLASS

template_cr="elasticsearch-template.yaml"
env_file="elasticsearch-env.yaml"
profile=${INSTANA_INSTALL_PROFILE:-"template"}

OUT_DIR=$(get_make_manifest_home)
MANIFEST="${OUT_DIR}/elasticsearch-env-${INSTANA_VERSION}.yaml"

check_replace_manifest $MANIFEST $replace_manifest
copy_template_manifest $template_cr $MANIFEST $profile

cr_env $template_cr $env_file $MANIFEST $profile

# post gen

# remove security context if openshift

echo updated elasticsearch manifest $MANIFEST, profile $profile
