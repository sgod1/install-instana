#!/bin/bash

source ../instana.env
source ./help-functions.sh

OUT_DIR=$(get_make_manifest_home)
MANIFEST=$OUT_DIR/$MANIFEST_FILENAME_CASSANDRA_SCC

if ! is_platform_ocp $PLATFORM; then
   echo cassandra scc is openshift specific, does not apply to $PLATFORM
   echo
   exit 1
fi

replace_manifest=${1:-"noreplace"}

check_replace_manifest $MANIFEST $replace_manifest
echo writing cassandra-scc to $MANIFEST

cat << EOF > $MANIFEST
apiVersion: security.openshift.io/v1
kind: SecurityContextConstraints
metadata:
  name: cassandra-scc
runAsUser:
  type: MustRunAs
  uid: 999
seLinuxContext:
  type: RunAsAny
fsGroup:
  type: RunAsAny
allowHostDirVolumePlugin: false
allowHostNetwork: true
allowHostPorts: true
allowPrivilegedContainer: false
allowHostIPC: true
allowHostPID: true
readOnlyRootFilesystem: false
users:
  - system:serviceaccount:instana-cassandra:cass-operator
  - system:serviceaccount:instana-cassandra:default
EOF
