#!/bin/bash

source ../instana.env
source ./install.env
source ./help-functions.sh

MANIFEST_HOME=$(get_manifest_home)

MANIFEST=$(format_file_path $MANIFEST_HOME $MANIFEST_FILENAME_CLICKHOUSE $INSTANA_INSTALL_PROFILE $INSTANA_VERSION)

echo applying clickhouse manifest $MANIFEST, namespace instana-clickhouse

if test ! -f $MANIFEST; then
   echo manifest $MANIFEST not found
   exit 1
fi

$KUBECTL apply -f $MANIFEST -n instana-clickhouse
rc=$?

check_return_code $rc

# todo check cr status

return $rc
