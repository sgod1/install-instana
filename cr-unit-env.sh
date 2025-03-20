#!/bin/bash

source ../instana.env
source ./help-functions.sh
source ./install.env
source ./cr-env.sh

export instana_tenant_unit="${INSTANA_TENANT_NAME}-${INSTANA_UNIT_NAME}"
export instana_tenant=$INSTANA_TENANT_NAME
export instana_unit=$INSTANA_UNIT_NAME
export resource_profile=$CORE_RESOURCE_PROFILE

replace_manifest=${1:-"noreplace"}

template_cr="unit-template.yaml"
env_file="unit-env.yaml"
profile=${INSTANA_INSTALL_PROFILE}

OUT_DIR=$(get_make_manifest_home)

manifest=$(format_file_path $OUT_DIR "unit.yaml" $profile $INSTANA_VERSION)

check_replace_manifest $manifest $replace_manifest
copy_template_manifest $template_cr $manifest $profile

cr_env $template_cr $env_file $manifest $profile

echo updated unit manifest $manifest, profile $profile
