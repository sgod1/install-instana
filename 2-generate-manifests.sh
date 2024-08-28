#!/bin/bash

echo ""
echo generating manifests...
echo ""

./cr-beeinstana.sh
./cr-cassandra-scc.sh
./cr-cassandra.sh
./cr-clickhouse-scc.sh
./cr-clickhouse.sh
./cr-elasticsearch.sh
./cr-kafka.sh
./cr-postgres.sh
./cr-zookeeper.sh
./cr-core.sh
./cr-unit.sh
