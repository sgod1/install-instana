#!/bin/bash

source ../instana.env
source ./help-functions.sh

OUT_DIR=$(get_make_manifest_home)

echo writing cassandra to $OUT_DIR/$MANIFEST_FILENAME_CASSANDRA

cat << EOF > $OUT_DIR/$MANIFEST_FILENAME_CASSANDRA
apiVersion: cassandra.datastax.com/v1beta1
kind: CassandraDatacenter
metadata:
  name: cassandra
spec:
  clusterName: instana
  serverType: cassandra
  serverImage: $PRIVATE_REGISTRY/self-hosted-images/3rd-party/datastore/cassandra:4.1.4_v0.17.0
  systemLoggerImage: $PRIVATE_REGISTRY/self-hosted-images/3rd-party/datastore/system-logger:1.18.2_v0.3.0
  k8ssandraClientImage: $PRIVATE_REGISTRY/self-hosted-images/3rd-party/datastore/k8ssandra-client:0.2.2_v0.3.0
  serverVersion: "4.1.4"
  imagePullPolicy: Always
  podTemplateSpec:
    spec:
      imagePullSecrets:
      - name: instana-registry
      containers:
      - name: cassandra
  managementApiAuth:
    insecure: {}
  size: 3
  allowMultipleNodesPerWorker: false
  resources:
    requests:
      cpu: 2000m
      memory: 8Gi
    limits:
      cpu: 4000m
      memory: 16Gi
  storageConfig:
    cassandraDataVolumeClaimSpec:
      accessModes:
        - ReadWriteOnce
      resources:
        requests:
          storage: 100Gi
  config:
    jvm-server-options:
      initial_heap_size: "4G"
      max_heap_size: "8G"
      additional-jvm-opts:
        - -Dcassandra.allow_unsafe_aggressive_sstable_expiration=true
    cassandra-yaml:
      authenticator: org.apache.cassandra.auth.PasswordAuthenticator
      authorizer: org.apache.cassandra.auth.CassandraAuthorizer
      role_manager: org.apache.cassandra.auth.CassandraRoleManager
      memtable_flush_writers: 8
      auto_snapshot: false
      gc_warn_threshold_in_ms: 10000
      otc_coalescing_strategy: DISABLED
      memtable_allocation_type: offheap_objects
      num_tokens: 256
      drop_compact_storage_enabled: true
EOF
