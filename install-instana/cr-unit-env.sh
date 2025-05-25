#!/bin/bash

source ../instana.env
source ./install.env
source ./help-functions.sh
source ./install.env
source ./cr-env.sh

export PATH=".:$PATH"

export instana_tenant_unit="${INSTANA_TENANT_NAME}-${INSTANA_UNIT_NAME}"
export instana_tenant=$INSTANA_TENANT_NAME
export instana_unit=$INSTANA_UNIT_NAME
export resource_profile=$CORE_RESOURCE_PROFILE

replace_manifest=${1:-"noreplace"}

template_cr=$CR_TEMPLATE_FILENAME_UNIT
env_file=$CR_ENV_FILENAME_UNIT
profile=${INSTANA_INSTALL_PROFILE}

OUT_DIR=$(get_make_manifest_home)

manifest=$(format_file_path $OUT_DIR $MANIFEST_FILENAME_UNIT $profile $INSTANA_VERSION)

check_replace_manifest $manifest $replace_manifest
copy_template_manifest $template_cr $manifest $profile

# tolerations
idx=$(./gen/bin/yq '.spec.componentConfigs.[]|select(.name=="appdata-legacy-converter")|path|.[-1]' $manifest)
tolpaths=".spec.componentConfigs[$idx].tolerations"

idx=$(./gen/bin/yq '.spec.componentConfigs.[]|select(.name=="appdata-processor")|path|.[-1]' $manifest)
tolpaths="$tolpaths .spec.componentConfigs[$idx].tolerations"

idx=$(./gen/bin/yq '.spec.componentConfigs.[]|select(.name=="filler")|path|.[-1]' $manifest)
tolpaths="$tolpaths .spec.componentConfigs[$idx].tolerations"

idx=$(./gen/bin/yq '.spec.componentConfigs.[]|select(.name=="issue-tracker")|path|.[-1]' $manifest)
tolpaths="$tolpaths .spec.componentConfigs[$idx].tolerations"

idx=$(./gen/bin/yq '.spec.componentConfigs.[]|select(.name=="processor")|path|.[-1]' $manifest)
tolpaths="$tolpaths .spec.componentConfigs[$idx].tolerations"

idx=$(./gen/bin/yq '.spec.componentConfigs.[]|select(.name=="ui-backend")|path|.[-1]' $manifest)
tolpaths="$tolpaths .spec.componentConfigs[$idx].tolerations"

export unit_toleration_key=${UNIT_TOLERATION_KEY:-${TOLERATION_KEY:-"nokey"}}
export unit_toleration_value=${UNIT_TOLERATION_VALUE:-${TOLERATION_VALUE:-"novalue"}}

cr-tolerations.sh $manifest $unit_toleration_key $unit_toleration_value $tolpaths
check_return_code $?

# env
cr_env $template_cr $env_file $manifest $profile
check_return_code $?

echo updated unit manifest $manifest, profile $profile
