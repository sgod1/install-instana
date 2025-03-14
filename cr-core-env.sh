#!/bin/bash

source ../instana.env
source ./datastore-images.env
source ./help-functions.sh
source ./cr-env.sh
source ./release.env

replace_manifest=${1:-"noreplace"}

export instana_base_domain=${INSTANA_BASE_DOMAIN}
export private_registry=${PRIVATE_REGISTRY}
export core_image_tag=${__instana_sem_version["${INSTANA_VERSION}"]}

export rwo_storageclass=${RWO_STORAGECLASS}
export rwx_storageclass=${RWX_STORAGECLASS}

template_cr="core-template.yaml"
env_file="core-env.yaml"
profile=${INSTANA_INSTALL_PROFILE:-"template"}

OUT_DIR=$(get_make_manifest_home)
MANIFEST="${OUT_DIR}/core-env-${INSTANA_VERSION}.yaml"

check_replace_manifest $MANIFEST $replace_manifest
copy_template_manifest $template_cr $MANIFEST $profile

cr_env $template_cr $env_file $MANIFEST $profile

echo updated core manifest $MANIFEST, profile $profile
