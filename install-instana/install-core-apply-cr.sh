#!/bin/bash

source ../instana.env
source ./help-functions.sh
source ./install.env

# extend path
PATH=".:$PATH"

# debug offline
offline_mode=$1

# instana-core secret
core-instana-core-secret.sh $offline_mode
check_return_code $?

# core-tls secret
core-instana-tls-secret.sh $offline_mode
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

# debug offline
if test $offline_mode; then
   online=""
   offline="offline"

else
   online="online"
fi

# apply cr
if test $online; then
   $KUBECTL apply -n instana-core -f $manifest
   check_return_code $?
else
   echo offline
fi

exit 0
