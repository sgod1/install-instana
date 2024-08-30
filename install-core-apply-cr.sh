#!/bin/bash

source ../instana.env
source ./help-functions.sh

replace_manifest=${1:-"no_replace"}

# create instana-core secret from core-config.yaml
./util-core-instana-core-secret-1.sh $replace_manifest
check_return_code $?

# create tls certs and instana-tls secret
./util-core-instana-tls-secret-2.sh $replace_manifest
check_return_code $?

# apply instana-core manifest
./util-core-apply-cr-3.sh 
check_return_code $?

