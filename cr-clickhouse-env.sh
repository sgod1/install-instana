#!/bin/bash

source ../instana.env
source ./datastore-images.env
source ./help-functions.sh
source ./cr-env.sh

replace_manifest=${1:-"noreplace"}

export clickhouse_container_image=${PRIVATE_REGISTRY}/${CLICKHOUSE_OPENSSL_IMG}
export clickhouse_log_image=${PRIVATE_REGISTRY}/${CLICKHOUSE_OPENSSL_IMG}

export rwo_storageclass=${RWO_STORAGECLASS}

export clickhouse_default_pass=${CLICKHOUSE_DEFAULT_PASS}
export clickhouse_user_pass=${CLICKHOUSE_USER_PASS}

template_cr="clickhouse-template.yaml"
env_file="clickhouse-env.yaml"
profile=${INSTANA_INSTALL_PROFILE:-"template"}

OUT_DIR=$(get_make_manifest_home)
MANIFEST="${OUT_DIR}/clickhouse-env-${INSTANA_VERSION}.yaml"

check_replace_manifest $MANIFEST $replace_manifest
cp $template_cr $MANIFEST

cr_env $template_cr $env_file $MANIFEST $profile

echo updated clickhouse manifest $MANIFEST
