#!/bin/bash

source ../instana.env
source ./install.env
source ./help-functions.sh

MANIFEST_HOME=$(get_manifest_home)

MANIFEST=$(format_file_path $MANIFEST_HOME $MANIFEST_FILENAME_POSTGRES $INSTANA_INSTALL_PROFILE $INSTANA_VERSION)

#
# create postgres secret, do not overwite secret file
#
POSTGRES_SECRET_FILE="$MANIFEST_HOME/postgres-secret-${INSTANA_VERSION}.yaml"

echo creating postgres secret $POSTGRES_SECRET_FILE

if test ! -f $POSTGRES_SECRET_FILE; then
cat << EOF > $POSTGRES_SECRET_FILE
kind: Secret
apiVersion: v1
metadata:
   name: instanaadmin
type: Opaque
stringData:
   username: instanaadmin
   password: `openssl rand -base64 24 | tr -cd 'a-zA-Z0-9' | head -c32; echo`
EOF
fi

$KUBECTL -n instana-postgres apply -f $POSTGRES_SECRET_FILE
check_return_code $?

#
# apply postgres cr
#
echo applying postgres cr $MANIFEST, namespace instana-postgres

if test ! -f $MANIFEST; then
   echo manifest $MANIFEST not found
   exit 1
fi

# deploy postgres cr
$KUBECTL -n instana-postgres apply -f $MANIFEST
check_return_code $?

#conditions:
#    - lastTransitionTime: "2025-03-24T20:20:53Z"
#      message: Cluster is Ready
#      reason: ClusterIsReady
#      status: "True"
#      type: Ready

exit 0
