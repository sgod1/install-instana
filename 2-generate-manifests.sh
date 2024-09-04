#!/bin/bash

echo ""
echo generating manifests...
echo ""

replace_manifest=${1:-"noreplace"}

./cr-beeinstana.sh $replace_manifest
./cr-cassandra-scc.sh $replace_manifest
./cr-cassandra.sh $replace_manifest
./cr-clickhouse-scc.sh $replace_manifest
./cr-clickhouse.sh $replace_manifest
./cr-elasticsearch.sh $replace_manifest
./cr-kafka.sh $replace_manifest
./cr-postgres.sh $replace_manifest
./cr-zookeeper.sh $replace_manifest
./cr-core.sh $replace_manifest
./cr-unit.sh $replace_manifest
