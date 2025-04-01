#!/bin/bash

source ./help-functions.sh

bin_home=$(get_bin_home)
export PATH=".:$bin_home:$PATH"

echo ""
echo generating manifests...
echo ""

replace_manifest=${1:-"noreplace"}

cr-beeinstana-env.sh $replace_manifest; check_return_code $?
#cr-cassandra-scc.sh $replace_manifest; check_return_code $?
cr-cassandra-env.sh $replace_manifest; check_return_code $?
#cr-clickhouse-scc.sh $replace_manifest; check_return_code $?
cr-clickhouse-env.sh $replace_manifest; check_return_code $?
cr-elasticsearch-env.sh $replace_manifest; check_return_code $?
cr-kafka-env.sh $replace_manifest; check_return_code $?
cr-postgres-env.sh $replace_manifest; check_return_code $?
cr-zookeeper-env.sh $replace_manifest; check_return_code $?
cr-core-env.sh $replace_manifest; check_return_code $?
cr-unit-env.sh $replace_manifest; check_return_code $?
cr-instana-operator.sh $replace_manifest; check_return_code $?
