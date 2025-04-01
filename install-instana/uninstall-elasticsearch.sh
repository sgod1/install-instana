#!/bin/bash

source ../instana.env
source ./help_functions.sh

bin_home=$(get_bin_home)
export PATH=".:$bin_home:$PATH"

set -x

echo delete elasticsearch instana, namespace elasticsearch

$KUBECTL -n instana-elasticsearch delete elasticsearch instana --wait=false
$KUBECTL -n instana-elasticsearch wait --for=delete pod -l"elasticsearch.k8s.elastic.co/cluster-name"=instana --timeout=${WAIT_TIMEOUT:-"600s"}

echo uninstall helm release elastic-operator, namesapce elasticsearch
helm uninstall elastic-operator	-n instana-elasticsearch
$KUBECTL -n instana-elasticsearch wait --for=delete pod -l"app.kubernetes.io/name"="elastic-operator" --timeout=${WAIT_TIMEOUT:-"600s"}
