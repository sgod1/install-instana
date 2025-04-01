#!/bin/bash


source ../instana.env
source ./help-functions.sh

bin_home=$(get_bin_home)
export PATH=".:$bin_home:$PATH"

set -x

echo "Deleteing cassandra datacenter cassandra..."
$KUBECTL -n instana-cassandra delete cassandradatacenter cassandra --wait=false
${KUBECTL} -n instana-cassandra wait --for=delete pod -lapp.kubernetes.io/name=cassandra --timeout=600s

echo "Deleting cassandra operator..."
helm uninstall cassandra-operator -n instana-cassandra
$KUBECTL -n instana-kafka wait --for=delete pod -lapp.kubernetes.io/name=cass-operator --timeout=${WAIT_TIMEOUT:-"600s"}
