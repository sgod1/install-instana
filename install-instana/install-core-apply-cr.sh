#!/bin/bash

source ../instana.env
source ./help-functions.sh
source ./install.env

# extend path
PATH=".:$PATH"

# crypto prefixes (qualifiers)
sp_crypto_prefix=${1:-"sp"};
ingress_crypto_prefix=${2:-"ingress"}

# instana-core secret
core-instana-core-secret.sh $sp_crypto_prefix
check_return_code $?

# core-tls secret
core-instana-tls-secret.sh $ingress_crypto_prefix
check_return_code $?

manifest_home=$(get_manifest_home)
MANIFEST=$manifest_home/$MANIFEST_FILENAME_CORE

manifest=$(format_file_path $manifest_home $MANIFEST_FILENAME_CORE $INSTANA_INSTALL_PROFILE $INSTANA_VERSION)

# apply instana-core manifest
log_msg $0 applying core manifest $manifest

if test ! -f $manifest; then
   log_msg $0 core manifest file $manifest not found

   exit 1
fi

# apply cr
$KUBECTL apply -n instana-core -f $manifest
check_return_code $?

exit 0
