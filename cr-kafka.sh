#!/bin/bash

source ../instana.env
source ./help-functions.sh

OUT_DIR=$(get_make_manifest_home)
MANIFEST=$OUT_DIR/$MANIFEST_FILENAME_KAFKA

replace_manifest=${1:-"noreplace"}

check_replace_manifest $MANIFEST $replace_manifest

echo writing kafka to $MANIFEST

cat << EOF > $MANIFEST
apiVersion: kafka.strimzi.io/v1beta2
kind: Kafka
metadata:
  name: instana
  labels:
    strimzi.io/cluster: instana
spec:
  kafka:
    image: $PRIVATE_REGISTRY/self-hosted-images/3rd-party/datastore/kafka:0.41.0-kafka-3.6.2_v0.7.0
    version: 3.6.2
    replicas: 3
    listeners:
      - name: scram
        port: 9092
        type: internal
        tls: false
        authentication:
          type: scram-sha-512
        configuration:
          useServiceDnsDomain: true
    authorization:
      type: simple
      superUsers:
        - strimzi-kafka-user
    storage:
      type: jbod
      volumes:
        - id: 0
          type: persistent-claim
          size: 50Gi
          deleteClaim: true
  zookeeper:
    replicas: 3
    storage:
      type: persistent-claim
      size: 5Gi
      deleteClaim: true
      class: $RWO_STORAGECLASS
  entityOperator:
    template:
      pod:
        tmpDirSizeLimit: 100Mi

EOF

if ! is_platform_ocp $PLATFORM; then
cat << EOF >> $MANIFEST
        # Add the following securityContext snippet for Kubernetes offerings other than OCP.
        securityContext:
          runAsUser: 1000
          fsGroup: 1000

EOF
fi

cat << EOF >> $MANIFEST
    userOperator:
      image: $PRIVATE_REGISTRY/self-hosted-images/3rd-party/operator/strimzi:0.41.0_v0.9.0
---
apiVersion: kafka.strimzi.io/v1beta2
kind: KafkaUser
metadata:
  name: strimzi-kafka-user
  labels:
    strimzi.io/cluster: instana
spec:
  authentication:
    type: scram-sha-512
  authorization:
    type: simple
    acls:
      - resource:
          type: topic
          name: '*'
          patternType: literal
        operation: All
        host: "*"
      - resource:
          type: group
          name: '*'
          patternType: literal
        operation: All
        host: "*"
EOF

