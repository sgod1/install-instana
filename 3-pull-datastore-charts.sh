#!/bin/bash

source ../instana.env

source ./help-functions.sh

source ./datastore-images.env
source ./certmgr-images.env

BIN_HOME=$(get_bin_home)
export PATH=".:$BIN_HOME:$PATH"

CHART_HOME=$(get_make_chart_home)
CHART_HOME=${CHART_HOME}/${INSTANA_VERSION}

mkdir -p $CHART_HOME

helm_repo=https://helm.instana.io/artifactory/rel-helm-customer-virtual
helm repo add instana $helm_repo --username _ --password $DOWNLOAD_KEY
check_return_code $?

helm repo update
check_return_code $?

echo "... pulling operator charts, INSTANA_VERSION=$INSTANA_VERSION, helm repo $helm_repo"

set -x

# zookeeper operator
helm pull instana/zookeeper-operator --version=${ZOOKEEPER_OPERATOR_CHART_VERSION} -d $CHART_HOME
check_return_code $? 2>/dev/null

# kafka operator
helm pull instana/strimzi-kafka-operator --version=${KAFKA_OPERATOR_CHART_VERSION} -d $CHART_HOME
check_return_code $? 2>/dev/null

# elasticsearch
helm pull instana/eck-operator --version=${ELASTICSEARCH_OPERATOR_CHART_VERSION} -d $CHART_HOME
check_return_code $? 2>/dev/null

# postgres
helm pull instana/cloudnative-pg --version="${POSTGRES_OPERATOR_CHART_VERSION}" -d $CHART_HOME
check_return_code $? 2>/dev/null

# cassandra
helm pull instana/cass-operator --version=${CASSANDRA_OPERATOR_CHART_VERSION} -d $CHART_HOME
check_return_code $? 2>/dev/null

# clickhouse
helm pull instana/ibm-clickhouse-operator --version=${CLICKHOUSE_OPERATOR_CHART_VERSION} -d $CHART_HOME
check_return_code $? 2>/dev/null

# beeinstana
helm pull instana/beeinstana-operator --version=${BEEINSTANA_OPERATOR_CHART_VERSION} -d $CHART_HOME
check_return_code $? 2>/dev/null

# cert-manager
helm pull instana/cert-manager --version=${CERTMGR_OPERATOR_CHART_VERSION} -d $CHART_HOME
check_return_code $? 2>/dev/null
