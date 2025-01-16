#!/bin/bash

INSTANA_VERSION_OVERRIDE=$1

source ../instana.env

source ./datastore-images.env

source ./help-functions.sh

MIRROR_HOME=$(get_mirror_home)

MIRROR_HOME=${MIRROR_HOME}/${INSTANA_VERSION}
mkdir -p $MIRROR_HOME

ARTIFACT_PUBLIC="artifact-public.instana.io"

echo writing datastore image list to ${MIRROR_HOME}/${INSTANA_DATASTORE_IMAGE_LIST_FILE}, Instana version: ${INSTANA_VERSION}

echo "
# Datastore images, Instana version: $INSTANA_VERSION
" > ${MIRROR_HOME}/${INSTANA_DATASTORE_IMAGE_LIST_FILE}

echo "# cassandra
${ARTIFACT_PUBLIC}/${CASSANDRA_OPERATOR_IMG}
${ARTIFACT_PUBLIC}/${CASSANDRA_SYSTEM_LOGGER_IMG}
${ARTIFACT_PUBLIC}/${CASSANDRA_K8S_CLIENT_IMG}
${ARTIFACT_PUBLIC}/${CASSANDRA_IMG}
" >> ${MIRROR_HOME}/${INSTANA_DATASTORE_IMAGE_LIST_FILE}

# cassandra config builder image in datastax container repo
if test ! -z "${CASSANDRA_CONFIG_BUILDER_IMG}"; then
echo "${CASSANDRA_DATASTAX_REPO}/${CASSANDRA_CONFIG_BUILDER_IMG}
" >> ${MIRROR_HOME}/${INSTANA_DATASTORE_IMAGE_LIST_FILE}
fi

echo "# clickhouse
${ARTIFACT_PUBLIC}/${CLICKHOUSE_OPERATOR_IMG}
${ARTIFACT_PUBLIC}/${CLICKHOUSE_OPENSSL_IMG}
" >> ${MIRROR_HOME}/${INSTANA_DATASTORE_IMAGE_LIST_FILE}

echo "# elasticsearch
${ARTIFACT_PUBLIC}/${ELASTICSEARCH_OPERATOR_IMG}
${ARTIFACT_PUBLIC}/${ELASTICSEARCH_IMG}
" >> ${MIRROR_HOME}/${INSTANA_DATASTORE_IMAGE_LIST_FILE}

echo "# kafka
${ARTIFACT_PUBLIC}/${KAFKA_OPERATOR_IMG}
${ARTIFACT_PUBLIC}/${KAFKA_IMG}
" >> ${MIRROR_HOME}/${INSTANA_DATASTORE_IMAGE_LIST_FILE}

echo "# postgresql
${ARTIFACT_PUBLIC}/${POSTGRES_OPERATOR_IMG}
${ARTIFACT_PUBLIC}/${POSTGRES_IMG}
" >> ${MIRROR_HOME}/${INSTANA_DATASTORE_IMAGE_LIST_FILE}

echo "# zookeeper
${ARTIFACT_PUBLIC}/${ZOOKEEPER_OPERATOR_IMG}
${ARTIFACT_PUBLIC}/${ZOOKEEPER_IMG}
${ARTIFACT_PUBLIC}/${ZOOKEEPER_KUBECTL_IMG}
" >> ${MIRROR_HOME}/${INSTANA_DATASTORE_IMAGE_LIST_FILE}

echo "# beeinstana
${BEEINSTANA_IMG_PLATFORM} ${ARTIFACT_PUBLIC}/${BEEINSTANA_OPERATOR_IMG}
${BEEINSTANA_IMG_PLATFORM} ${ARTIFACT_PUBLIC}/${BEEINSTANA_AGGREGATOR_IMG}
${BEEINSTANA_IMG_PLATFORM} ${ARTIFACT_PUBLIC}/${BEEINSTANA_MONCONFIG_IMG}
${BEEINSTANA_IMG_PLATFORM} ${ARTIFACT_PUBLIC}/${BEEINSTANA_INGESTOR_IMG}
" >> ${MIRROR_HOME}/${INSTANA_DATASTORE_IMAGE_LIST_FILE}

