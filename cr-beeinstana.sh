#!/bin/bash

source ../instana.env
source ./help-functions.sh
source ./datastore-images.env

OUT_DIR=$(get_make_manifest_home)

MANIFEST="$OUT_DIR/$MANIFEST_FILENAME_BEEINSTANA"

replace_manifest=${1:-"no_replace"}

check_replace_manifest $MANIFEST $replace_manifest

echo writing beeinstana to $MANIFEST

beeinstana_monconfig_img_repo=`echo ${BEEINSTANA_MONCONFIG_IMG} | cut -d : -f 1 -`
beeinstana_monconfig_img_tag=`echo ${BEEINSTANA_MONCONFIG_IMG} | cut -d : -f 2 -`

beeinstana_ingestor_img_repo=`echo ${BEEINSTANA_INGESTOR_IMG} | cut -d : -f 1 -`
beeinstana_ingestor_img_tag=`echo ${BEEINSTANA_INGESTOR_IMG} | cut -d : -f 2 -`

beeinstana_aggregator_img_repo=`echo ${BEEINSTANA_AGGREGATOR_IMG} | cut -d : -f 1 -`
beeinstana_aggregator_img_tag=`echo ${BEEINSTANA_AGGREGATOR_IMG} | cut -d : -f 2 -`

cat << EOF > $MANIFEST
apiVersion: beeinstana.instana.com/v1beta1
kind: BeeInstana
metadata:
  name: instance
  namespace: beeinstana
spec:
  version: 1.3.12
  imageRegistry: $PRIVATE_REGISTRY
  adminCredentials:
    secretName: beeinstana-admin-creds
  kafkaSettings:
    brokers:
      # Update KAFKA_NAMESPACE to the namespace where Kafka is installed
      - instana-kafka-bootstrap.instana-kafka:9092
    securityProtocol: SASL_PLAINTEXT
    saslMechanism: SCRAM-SHA-512
    saslPasswordCredential:
      secretName: beeinstana-kafka-creds
  config:
    cpu: 200m
    memory: 200Mi
    replicas: 1
    image:
      name: ${beeinstana_monconfig_img_repo}
      tag: ${beeinstana_monconfig_img_tag}
  ingestor:
    cpu: 8
    memory: 4Gi
    limitMemory: true
    env: on-prem
    metricsTopic: raw_metrics
    replicas: 1
    image:
      name: ${beeinstana_ingestor_img_repo}
      tag: ${beeinstana_ingestor_img_tag}
  aggregator:
    cpu: 4
    memory: 16Gi
    limitMemory: true
    mirrors: 2
    shards: 1
    volumes:
      live:
        size: 500Gi
        storageClass: $RWO_STORAGECLASS
    image:
      name: ${beeinstana_aggregator_img_repo}
      tag: ${beeinstana_aggregator_img_tag}
  # Should set useMultiArchImages to true for s390x and ppc64le
  useMultiArchImages: false
EOF
