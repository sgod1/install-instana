#!/bin/bash

source ../instana.env
source ./help-functions.sh
source ./datastore-images.env

OUT_DIR=$(get_make_manifest_home)
MANIFEST=$OUT_DIR/$MANIFEST_FILENAME_POSTGRES

replace_manifest=${1:-"noreplace"}

check_replace_manifest $MANIFEST $replace_manifest

echo writing postgres manifest to $MANIFEST

cat << EOF > $MANIFEST
apiVersion: postgresql.cnpg.io/v1
kind: Cluster
metadata:
  name: postgres
spec:
  instances: 3
  imageName: ${PRIVATE_REGISTRY}/${POSTRGES_IMG}
  imagePullPolicy: IfNotPresent
  postgresql:
    parameters:
      shared_buffers: 32MB
      pg_stat_statements.track: all
      auto_explain.log_min_duration: '10s'
    pg_hba:
      - local     all          all                            trust
      - host      all          all          0.0.0.0/0         md5
      - local     replication  standby                        trust
      - hostssl   replication  standby      all               md5
      - hostnossl all          all          all               reject
      - hostssl   all          all          all               md5
  managed:
    roles:
    - name: instanaadmin
      login: true
      superuser: true
      createdb: true
      createrole: true
      passwordSecret:
        name: instanaadmin
  bootstrap:
    initdb:
      database: instanaadmin
      owner: instanaadmin
      secret:
        name: instanaadmin
  superuserSecret:
    name: instanaadmin
  storage:
    size: 1Gi
    storageClass: $RWO_STORAGECLASS
EOF
