#!/bin/bash

source ../instana.env

source ./help-functions.sh

MIRROR_HOME=$(get_mirror_home)

mkdir -p $MIRROR_HOME

echo writing datastore image list to ${MIRROR_HOME}/${INSTANA_DATASTORE_IMAGE_LIST_FILE}

echo "
# cassandra
artifact-public.instana.io/self-hosted-images/3rd-party/operator/cass-operator:1.18.2_v0.12.0
artifact-public.instana.io/self-hosted-images/3rd-party/datastore/system-logger:1.18.2_v0.3.0
artifact-public.instana.io/self-hosted-images/3rd-party/datastore/k8ssandra-client:0.2.2_v0.3.0
artifact-public.instana.io/self-hosted-images/3rd-party/datastore/cassandra:4.1.4_v0.17.0

# clickhouse
artifact-public.instana.io/clickhouse-operator:v0.1.2
artifact-public.instana.io/clickhouse-openssl:23.8.9.54-1-lts-ibm
artifact-public.instana.io/clickhouse-openssl:23.8.10.43-1-lts-ibm

# elasticsearch
artifact-public.instana.io/self-hosted-images/3rd-party/operator/elasticsearch:2.9.0_v0.11.0
artifact-public.instana.io/self-hosted-images/3rd-party/datastore/elasticsearch:7.17.20_v0.9.0

# kafka
artifact-public.instana.io/self-hosted-images/3rd-party/operator/strimzi:0.41.0_v0.9.0
artifact-public.instana.io/self-hosted-images/3rd-party/datastore/kafka:0.41.0-kafka-3.6.2_v0.7.0

# postgres cloud native
artifact-public.instana.io/self-hosted-images/3rd-party/operator/cloudnative-pg:v1.21.1_v0.5.0
artifact-public.instana.io/self-hosted-images/3rd-party/datastore/cnpg-containers:15_v0.6.0

# zookeeper
artifact-public.instana.io/self-hosted-images/3rd-party/operator/zookeeper:0.2.15_v0.11.0
artifact-public.instana.io/self-hosted-images/3rd-party/datastore/zookeeper:3.8.3_v0.12.0
artifact-public.instana.io/lachlanevenson/k8s-kubectl:v1.23.2

# beeinstana
--platform linux/amd64 artifact-public.instana.io/beeinstana/operator:v1.58.0
artifact-public.instana.io/beeinstana/aggregator:v1.85.35-release
--platform linux/amd64 artifact-public.instana.io/beeinstana/monconfig:v2.19.0
artifact-public.instana.io/beeinstana/ingestor:v1.85.35-release

" > ${MIRROR_HOME}/${INSTANA_DATASTORE_IMAGE_LIST_FILE}
