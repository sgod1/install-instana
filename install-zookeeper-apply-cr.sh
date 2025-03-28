#!/bin/bash

source ../instana.env
source ./install.env
source ./help-functions.sh

MANIFEST_HOME=$(get_manifest_home)

MANIFEST=$(format_file_path $MANIFEST_HOME $MANIFEST_FILENAME_ZOOKEEPER $INSTANA_INSTALL_PROFILE $INSTANA_VERSION)

echo applying zookeeper cr $MANIFEST, namespace instana-clickhouse

if test ! -f $MANIFEST; then
   echo manifest $MANIFEST not found
   exit 1
fi

$KUBECTL apply -f $MANIFEST -n instana-clickhouse
check_return_code $?

#$KUBECTL -n instana-clickhouse wait --for=condition=Ready=true pod -lrelease=instana-zookeeper --timeout 600s
#check_return_code $?
