#!/bin/bash

source ../instana.env
source ./help-functions.sh
source ./install.env

# extend path
PATH=".:$PATH"

offline=$1

# create instana-core secret
core-instana-core-secret.sh $offline
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

$KUBECTL apply -n instana-core -f $manifest
