#!/bin/bash

source ../instana.env
source ./help-functions.sh

OUT_DIR=$(get_make_manifest_home)

echo writing clickhouse-scc to $OUT_DIR/$MANIFEST_FILENAME_CLICKHOUSE_SCC

cat << EOF > $OUT_DIR/$MANIFEST_FILENAME_CLICKHOUSE_SCC
apiVersion: security.openshift.io/v1
kind: SecurityContextConstraints
metadata:
  name: clickhouse-scc
runAsUser:
  type: MustRunAs
  uid: 1001
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
  - system:serviceaccount:instana-clickhouse:clickhouse-operator
  - system:serviceaccount:instana-clickhouse:clickhouse-operator-ibm-clickhouse-operator
  - system:serviceaccount:instana-clickhouse:default
EOF
