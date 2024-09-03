#!/bin/bash

source ../instana.env
source ./help-functions.sh

OUT_DIR=$(get_make_manifest_home)
MANIFEST=$OUT_DIR/$MANIFEST_FILENAME_ELASTICSEARCH

replace_manifest=${1:-"noreplace"}

check_replace_manifest $MANIFEST $replace_manifest

echo writing elasticsearch to $MANIFEST

cat << EOF > $MANIFEST
apiVersion: elasticsearch.k8s.elastic.co/v1
kind: Elasticsearch
metadata:
  name: instana
spec:
  version: 7.17.20
  image: $PRIVATE_REGISTRY/self-hosted-images/3rd-party/datastore/elasticsearch:7.17.20_v0.9.0
  nodeSets:
    - name: default
      count: 3
      config:
        node.master: true
        node.data: true
        node.ingest: true
        node.store.allow_mmap: false
      podTemplate:
        spec:
          imagePullSecrets:
            - name: instana-registry
          # Add the following securityContext snippet for Kubernetes offerings other than OCP.
          # securityContext:
          #   fsGroup: 1000
          #   runAsGroup: 1000
          #   runAsUser: 1000
          $ELASTICSEARCH_SECURITY_CONTEXT
      volumeClaimTemplates:
        - metadata:
            name: elasticsearch-data # Do not change this name unless you set up a volume mount for the data path.
          spec:
            accessModes:
              - ReadWriteOnce
            resources:
              requests:
                storage: 20Gi
            storageClassName: $RWO_STORAGECLASS
  http:
    tls:
      selfSignedCertificate:
        disabled: true
EOF
