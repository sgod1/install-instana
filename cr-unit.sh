#!/bin/bash

source ../instana.env
source ./help-functions.sh

MANIFEST_HOME=$(get_manifest_home)

MANIFEST=$MANIFEST_HOME/$MANIFEST_FILENAME_UNIT

replace_manifest=${1:-"noreplace"}

check_replace_manifest $MANIFEST $replace_manifest

echo writing core manifest to $MANIFEST

CORE_NAME="instana-core"
CORE_NAMESPACE="instana-core"

cat << EOF > $MANIFEST
apiVersion: instana.io/v1beta2
kind: Unit
metadata:
  name: ${INSTANA_TENANT_NAME}-${INSTANA_UNIT_NAME}
spec:
  # Must refer to the namespace of the associated Core object that was created previously
  coreName: $CORE_NAME

  # Must refer to the name of the associated Core object that was created previously
  coreNamespace: $CORE_NAMESPACE

  # The name of the tenant
  tenantName: $INSTANA_TENANT_NAME

  # The name of the unit within the tenant
  unitName: $INSTANA_UNIT_NAME

  # The same rules apply as for Cores. May be ommitted. Default is 'medium'
  resourceProfile: $CORE_RESOURCE_PROFILE
EOF
