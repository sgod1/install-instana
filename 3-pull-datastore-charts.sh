#!/bin/bash -x

source ../instana.env

source ./help-functions.sh

CHART_HOME=$(get_make_chart_home)

helm repo add instana https://helm.instana.io/artifactory/rel-helm-customer-virtual --username _ --password $DOWNLOAD_KEY

helm repo update

# zookeeper operator
helm pull instana/zookeeper-operator --version=0.2.15 -d $CHART_HOME

# kafka operator
helm pull instana/strimzi-kafka-operator --version=0.41.0 -d $CHART_HOME

# elasticsearch
helm pull instana/eck-operator --version=2.9.0 -d $CHART_HOME

# postgres
helm pull instana/cloudnative-pg --version=0.20.0 -d $CHART_HOME

# cassandra
helm pull instana/cass-operator --version=0.45.2 -d $CHART_HOME

# clickhouse
helm pull instana/ibm-clickhouse-operator --version=v0.1.2 -d $CHART_HOME

# beeinstana
helm pull instana/beeinstana-operator --version=v1.58.0 -d $CHART_HOME

# cert-manager
helm pull instana/cert-manager --version=v1.13.2 -d $CHART_HOME
