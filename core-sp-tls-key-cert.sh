#!/bin/bash

source ../instana.env
source ./help-functions.sh

profile=${1:-$INSTANA_INSTALL_PROFILE}

mkdir -p "gen/tls"
passfile="gen/tls/core-config-sp-key-pasword-${profile}-${INSTANA_VERSION}.pass"

echo "$CORE_CONFIG_SP_KEY_PASSWORD" > "$passfile"

./tls-key-cert.sh "sp" "$profile" "$passfile"
check_return_code $?
