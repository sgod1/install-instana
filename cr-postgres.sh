#!/bin/bash

source ../instana.env
source ./help-functions.sh

OUT_DIR=$(get_make_manifest_home)

echo writing postgres to $OUT_DIR/$MANIFEST_FILENAME_POSTGRES

cat << EOF > $OUT_DIR/$MANIFEST_FILENAME_POSTGRES
apiVersion: postgresql.cnpg.io/v1
kind: Cluster
metadata:
  name: postgres
spec:
  instances: 3
  imageName: $PRIVATE_REGISTRY/self-hosted-images/3rd-party/datastore/cnpg-containers:15_v0.6.0
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
