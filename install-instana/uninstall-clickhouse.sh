#!/bin/bash

source ../instana.env
source ./help-functions.sh

bin_home=$(get_bin_home)
export PATH=".:$bin_home:$PATH"

set -x

echo "Deleteing ClickHouseInstallation instana..."
$KUBECTL -n instana-clickhouse delete ClickHouseInstallation instana --wait=false
$KUBECTL -n instana-clickhouse wait --for=delete pod -l"clickhouse.altinity.com/chi"=instana --timeout=${WAIT_TIMEOUT:-"600s"}

echo "Deleting clickhouse-operator..."
helm uninstall clickhouse-operator -n instana-clickhouse
$KUBECTL -n instana-clickhouse wait --for=delete pod -l"app.kubernetes.io/name"="ibm-clickhouse-operator" --timeout=${WAIT_TIMEOUT:-"600s"}
