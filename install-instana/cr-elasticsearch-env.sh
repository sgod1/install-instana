#!/bin/bash

source ../instana.env
source ./install.env
source ./datastore-images.env
source ./help-functions.sh
source ./cr-env.sh

replace_manifest=${1:-"noreplace"}

export elasticsearch_version=${ELASTICSEARCH_VERSION}
export elasticsearch_image=$PRIVATE_REGISTRY/${ELASTICSEARCH_IMG}
export rwo_storageclass=$RWO_STORAGECLASS

template_cr=$CR_TEMPLATE_FILENAME_ELASTICSEARCH
env_file=$CR_ENV_FILENAME_ELASTICSEARCH
profile=${INSTANA_INSTALL_PROFILE:-"template"}

OUT_DIR=$(get_make_manifest_home)

MANIFEST=$(format_file_path $OUT_DIR $MANIFEST_FILENAME_ELASTICSEARCH $profile $INSTANA_VERSION)

check_replace_manifest $MANIFEST $replace_manifest
copy_template_manifest $template_cr $MANIFEST $profile

cr_env $template_cr $env_file $MANIFEST $profile
check_return_code $?

# post gen

# remove security context if openshift
if [[ $PLATFORM == "ocp" ]]; then
  echo "ocp ... deleting .spec.nodeSets.[]|select(.name == "default")|.podTemplate.spec.securityContext from $MANIFEST"
  $(get_bin_home)/yq -i 'del(.spec.nodeSets.[]|select(.name == "default")|.podTemplate.spec.securityContext)' $MANIFEST
fi

echo updated elasticsearch manifest $MANIFEST, profile $profile
