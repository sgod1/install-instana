#!/bin/bash

source ../instana.env
source ./help-functions.sh
source ./install.env

OUT_DIR=$(get_make_manifest_home)

MANIFEST=$(format_file_path $OUT_DIR $MANIFEST_FILENAME_CLICKHOUSE_SCC $INSTANA_INSTALL_PROFILE $INSTANA_VERSION)

if ! is_platform_ocp $PLATFORM; then
   echo clickhouse scc is openshift specific, does not apply to $PLATFORM
   echo
   exit 1
fi

replace_manifest=${1:-"noreplace"}

check_replace_manifest $MANIFEST $replace_manifest

echo writing clickhouse-scc manifest to $MANIFEST

cat << EOF > $MANIFEST
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
