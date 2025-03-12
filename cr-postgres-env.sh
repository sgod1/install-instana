#!/bin/bash

source ../instana.env
source ./datastore-images.env
source ./help-functions.sh
source ./cr-env.sh

replace_manifest=${1:-"noreplace"}

export postgres_image=${PRIVATE_REGISTRY}/${POSTGRES_IMG}
export rwo_storageclass=${RWO_STORAGECLASS}

template_cr="postgres-template.yaml"
env_file="postgres-env.yaml"
profile=${INSTANA_INSTALL_PROFILE:-"template"}

OUT_DIR=$(get_make_manifest_home)
MANIFEST="${OUT_DIR}/postgres-env-${INSTANA_VERSION}.yaml"

check_replace_manifest $MANIFEST $replace_manifest
copy_template_manifest $template_cr $MANIFEST $profile

cr_env $template_cr $env_file $MANIFEST $profile

echo updated postgres manifest $MANIFEST, profile $profile
