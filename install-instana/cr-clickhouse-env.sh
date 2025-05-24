#!/bin/bash

source ../instana.env
source ./install.env
source ./datastore-images.env
source ./help-functions.sh
source ./cr-env.sh

export PATH=".:$PATH"

replace_manifest=${1:-"noreplace"}

export clickhouse_container_image=${PRIVATE_REGISTRY}/${CLICKHOUSE_OPENSSL_IMG}
export clickhouse_log_image=${PRIVATE_REGISTRY}/${CLICKHOUSE_OPENSSL_IMG}

export rwo_storageclass=${RWO_STORAGECLASS}

export clickhouse_user_pass=${CLICKHOUSE_USER_PASS}
export clickhouse_admin_pass=${CLICKHOUSE_ADMIN_PASS}

template_cr=$CR_TEMPLATE_FILENAME_CLICKHOUSE
env_file=$CR_ENV_FILENAME_CLICKHOUSE
profile=${INSTANA_INSTALL_PROFILE:-"template"}

OUT_DIR=$(get_make_manifest_home)

MANIFEST=$(format_file_path $OUT_DIR $MANIFEST_FILENAME_CLICKHOUSE $profile $INSTANA_VERSION)

check_replace_manifest $MANIFEST $replace_manifest
cp $template_cr $MANIFEST

# tolerations
idx=$(./gen/bin/yq '.spec.templates.podTemplates[]|select(.name=="clickhouse")|path|.[-1]' $MANIFEST)
tolpaths=".spec.templates.podTemplates[$idx].spec.tolerations"

export clickhouse_toleration_key=${CLICKHOUSE_TOLERATION_KEY:-${TOLERATION_KEY:-"nokey"}}
export clickhouse_toleration_value=${CLICKHOUSE_TOLERATION_VALUE:-${TOLERATION_VALUE:-"novalue"}}

cr-tolerations.sh $MANIFEST $clickhouse_toleration_key $clickhouse_toleration_value $tolpaths
check_return_code $?

# env
cr_env $template_cr $env_file $MANIFEST $profile
check_return_code $?

echo updated clickhouse manifest $MANIFEST
