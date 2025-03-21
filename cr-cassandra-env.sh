#!/bin/bash

source ../instana.env
source ./install.env
source ./datastore-images.env
source ./help-functions.sh
source ./cr-env.sh

replace_manifest=${1:-"noreplace"}

export cassandra_server_image=${PRIVATE_REGISTRY}/${CASSANDRA_IMG}
export cassandra_system_logger_image=${PRIVATE_REGISTRY}/${CASSANDRA_SYSTEM_LOGGER_IMG}
export cassandra_client_image=${PRIVATE_REGISTRY}/${CASSANDRA_K8S_CLIENT_IMG}

# todo: update template with storage class
export rwo_storageclass=${RWO_STORAGECLASS}

template_cr=$CR_TEMPLATE_FILENAME_CASSANDRA
env_file=$CR_ENV_FILENAME_CASSANDRA
profile=${INSTANA_INSTALL_PROFILE:-"template"}

OUT_DIR=$(get_make_manifest_home)

MANIFEST=$(format_file_path $OUT_DIR $MANIFEST_FILENAME_CASSANDRA $profile $INSTANA_VERSION)

check_replace_manifest $MANIFEST $replace_manifest
copy_template_manifest $template_cr $MANIFEST $profile

cr_env $template_cr $env_file $MANIFEST $profile
check_return_code $?

echo updated cassandra manifest $MANIFEST, profile $profile

exit 0
