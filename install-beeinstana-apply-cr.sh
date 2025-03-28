#!/bin/bash

source ../instana.env
source ./install.env
source ./help-functions.sh

MANIFEST_HOME=$(get_manifest_home)

MANIFEST=$(format_file_path $MANIFEST_HOME $MANIFEST_FILENAME_BEEINSTANA $INSTANA_INSTALL_PROFILE $INSTANA_VERSION)

echo applying beeinstana manifest $MANIFEST, namespace beeinstana

if test ! -f $MANIFEST; then
   echo manifest $MANIFEST not found
   exit 1
fi

# create kafka creds secret
${KUBECTL} create secret generic beeinstana-kafka-creds -n beeinstana \
  --from-literal=username=strimzi-kafka-user \
  --from-literal=password=`${KUBECTL} get secret strimzi-kafka-user  -n instana-kafka --template='{{index .data.password | base64decode}}'`
check_return_code $?

# create beeinstana admin secret
${KUBECTL} create secret generic beeinstana-admin-creds -n beeinstana \
  --from-literal=username=beeinstana-user \
  --from-literal=password=${BEEINSTANA_ADMIN_PASS}
check_return_code $?

${KUBECTL} -n beeinstana apply -f $MANIFEST
check_return_code $?

echo patching beeinstana/instance uid-range
${KUBECTL} -n beeinstana patch beeinstana/instance --type=json --patch '
[
  {
    "op": "replace",
    "path": "/spec/fsGroup",
    "value": '`${KUBECTL} get namespace beeinstana -o jsonpath='{.metadata.annotations.openshift\.io\/sa\.scc\.uid-range}' | cut -d/ -f 1`'
  }
]'
check_return_code $?

exit 0
