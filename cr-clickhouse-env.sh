#!/bin/bash

source ../instana.env
source ./help-functions.sh
source ./cr-env.sh

export clickhouse_container_image=${PRIVATE_REGISTRY}/${CLICKHOUSE_OPENSSL_IMG}
export clickhouse_log_image=${PRIVATE_REGISTRY}/${CLICKHOUSE_OPENSSL_IMG}

export rwo_storageclass=${RWO_STORAGECLASS}

export clickhouse_default_pass=${CLICKHOUSE_DEFAULT_PASS}
export clickhouse_user_pass=${CLICKHOUSE_USER_PASS}

template_cr="clickhouse-template.yaml"
env_file="clikhouse-env.yaml"
out_file="gen/cr-clickhouse-289.yaml"
profile="uat"

cr-env $template_cr $env_file $out_file $profile
