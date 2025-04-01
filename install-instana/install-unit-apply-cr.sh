#!/bin/bash

source ../instana.env
source ./help-functions.sh
source ./install.env

INSTALL_HOME=$(get_install_home)
BIN_HOME=$(get_bin_home)
MANIFEST_HOME=$(get_manifest_home)

# check for license file
LICENSE_JSON=$BIN_HOME/license.json

echo checking for instana license $LICENSE_JSON
echo

if test ! -f $LICENSE_JSON; then
   echo instana license file $LICENSE_JSON not found
   exit 1
fi

# check for unit manifest
UNIT_MANIFEST=$(format_file_path $MANIFEST_HOME $MANIFEST_FILENAME_UNIT $INSTANA_INSTALL_PROFILE $INSTANA_VERSION)

echo cheking for unit manifest file $UNIT_MANIFEST
echo

if test ! -f $UNIT_MANIFEST; then
   echo unit manifest file $UNIT_MANIFEST not found
   exit 1
fi

# create unit-config.yaml
UNIT_CONFIG=$(format_file_path $MANIFEST_HOME "unit-config.yaml" $INSTANA_INSTALL_PROFILE $INSTANA_VERSION)

cat << EOF > $UNIT_CONFIG
# The initial user of this tenant unit with admin role, default admin@instana.local.
# Must be a valid e-maiol address.
# NOTE:
# This only applies when setting up the tenant unit.
# Changes to this value won't have any effect.
initialAdminUser: ${INSTANA_ADMIN_USER:-"admin@instana.local"}

# The initial admin password.
# NOTE:
# This is only used for the initial tenant unit setup.
# Changes to this value won't have any effect.
initialAdminPassword: ${INSTANA_ADMIN_PASSWORD:-"adminpass"}

# The Instana license. Can be a plain text string or a JSON array encoded as string. Deprecated. Use 'licenses' instead. Will no longer be supported in release 243.
# license: mylicensestring # This would also work: '["mylicensestring"]'
# A list of Instana licenses. Multiple licenses may be specified.
# licenses: [ "license1", "license2" ]
licenses: `cat $LICENSE_JSON`

# A list of agent keys. Specifying multiple agent keys enables gradually rotating agent keys.
agentKeys:
  - ${DOWNLOAD_KEY}

downloadKey: ${DOWNLOAD_KEY}
EOF

UNIT_SECRET="${INSTANA_TENANT_NAME}-${INSTANA_UNIT_NAME}"

echo "(re) creating unit secret $UNIT_SECRET, namespace instana-units"
echo

${KUBECTL} delete secret $UNIT_SECRET --namespace instana-units
${KUBECTL} create secret generic $UNIT_SECRET --namespace instana-units --from-file=config.yaml=$UNIT_CONFIG
check_return_code $?

echo creating instana-unit, mainfest $UNIT_MANIFEST, namespace instana-units
echo

${KUBECTL} apply -f $UNIT_MANIFEST -n instana-units
check_return_code $?

exit 0
