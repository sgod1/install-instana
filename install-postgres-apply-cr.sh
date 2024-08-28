#!/bin/bash

source ../instana.env
source ./help-functions.sh

MANIFEST_HOME=$(get_manifest_home)

MANIFEST=$MANIFEST_HOME/$MANIFEST_FILENAME_POSTGRES

#
# create postgres secret, do not overwite secret file
#
POSTGRES_SECRET_FILE=$MANIFEST_HOME/postgres-secret.yaml

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
