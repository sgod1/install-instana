#!/bin/bash

echo instana install start

echo initializing namespaces
./init-namespaces.sh

echo installing zookeeper
./install-zookeeper-operator.sh
./install-zookeeper-apply-cr.sh

echo installing kafka
./install-kafka-operator.sh
./install-kafka-apply-cr.sh

echo installing elasticsearch
./install-elasticsearch-operator.sh
./install-elasticsearch-apply-cr.sh

echo installing postgres
./install-postgres-operator.sh
./install-postgres-apply-cr.sh

echo installing cassandra
./install-cassandra-operator.sh
./install-cassandra-apply-cr.sh

echo installing clickhouse
./install-clickhouse-operator.sh
./install-clickhouse-apply-cr.sh

echo installing beeinstana
./install-beeinstana-operator.sh
./install-beeinstana-apply-cr.sh

echo installing instana operator
./install-instana-operator.sh

echo installing instana core
./install-core-apply-cr.sh

echo installing instana unit
./install-unit-apply-cr.sh

echo creating routes
./install-create-routes.sh

echo instana install end
