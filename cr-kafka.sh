#!/bin/bash

source ../instana.env
source ./help-functions.sh
source ./datastore-images.env

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
    image: ${PRIVATE_REGISTRY}/${KAFKA_IMG}
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
      image: ${PRIVATE_REGISTRY}/${KAFKA_OPERATOR_IMG}
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

