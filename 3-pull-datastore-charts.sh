#!/bin/bash

source ../instana.env

source ./help-functions.sh

source ./datastore-images.env

CHART_HOME=$(get_make_chart_home)

helm_repo=https://helm.instana.io/artifactory/rel-helm-customer-virtual
helm repo add instana $helm_repo --username _ --password $DOWNLOAD_KEY

helm repo update

echo "... pulling operator charts, INSTANA_VERSION=$INSTANA_VERSION, helm repo $helm_repo"

set -x

# zookeeper operator
helm pull instana/zookeeper-operator --version=${ZOOKEEPER_OPERATOR_CHART_VERSION} -d $CHART_HOME

# kafka operator
helm pull instana/strimzi-kafka-operator --version=${KAFKA_OPERATOR_CHART_VERSION} -d $CHART_HOME

# elasticsearch
helm pull instana/eck-operator --version=${ELASTICSEARCH_OPERATOR_CHART_VERSION} -d $CHART_HOME

# postgres
helm pull instana/cloudnative-pg --version="${POSTGRES_OPERATOR_CHART_VERSION}" -d $CHART_HOME

# cassandra
helm pull instana/cass-operator --version=${CASSANDRA_OPERATOR_CHART_VERSION} -d $CHART_HOME

# clickhouse
helm pull instana/ibm-clickhouse-operator --version=${CLICKHOUSE_OPERATOR_CHART_VERSION} -d $CHART_HOME

# beeinstana
helm pull instana/beeinstana-operator --version=${BEEINSTANA_OPERATOR_CHART_VERSION} -d $CHART_HOME

# cert-manager
helm pull instana/cert-manager --version=${CERTMGR_OPERATOR_CHART_VERSION} -d $CHART_HOME
