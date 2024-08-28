#!/bin/bash

source ../instana.env
source ./help-functions.sh

OUT_DIR=$(get_make_manifest_home)

echo writing cassandra-scc to $OUT_DIR/$MANIFEST_FILENAME_CASSANDRA_SCC

cat << EOF > $OUT_DIR/$MANIFEST_FILENAME_CASSANDRA_SCC
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
