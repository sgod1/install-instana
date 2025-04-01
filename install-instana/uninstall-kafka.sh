#!/bin/bash

source ../instana.env
source ./help-functions.sh

bin_home=$(get_bin_home)
export PATH=".:$bin_home:$PATH"

set -x

echo "Deleteing kafka instana..."
$KUBECTL -n instana-kafka delete kafka instana --wait=false
$KUBECTL -n instana-kafka wait --for=delete pod -l"strimzi.io/kind"=Kafka --timeout=${WAIT_TIMEOUT:-"600s"}

echo "Deleting kafka user..."
$KUBECTL -n instana-kafka delete kafkauser strimzi-kafka-user

echo "Deleting kafka-operator..."
helm uninstall kafka-operator -n instana-kafka
$KUBECTL -n instana-kafka wait --for=delete pod -lname="strimzi-cluster-operator" --timeout=${WAIT_TIMEOUT:-"600s"}
