#!/bin/bash

source ../instana.env
source ./help-functions.sh

set -x

# zookeeper
SNAPSHOT=${SNAPSHOT_HOME}/zookeeper-$(snapshot_name $INSTANA_VERSION).yaml
$KUBECTL get ZookeeperCluster/instana-zookeeper -n instana-clickhouse -o yaml > ${SNAPSHOT}

# kafka
SNAPSHOT=${SNAPSHOT_HOME}/kafka-$(snapshot_name $INSTANA_VERSION).yaml
$KUBECTL get Kafka/instana -n instana-kafka -o yaml > ${SNAPSHOT}

# elasticsearch
SNAPSHOT=${SNAPSHOT_HOME}/elasticsearch-$(snapshot_name $INSTANA_VERSION).yaml
$KUBECTL get Elasticsearch/instana -n instana-elasticsearch -o yaml > ${SNAPSHOT}

# postgres
SNAPSHOT=${SNAPSHOT_HOME}/postgres-$(snapshot_name $INSTANA_VERSION).yaml
$KUBECTL get cluster/postgres -n instana-postgres -n instana-postgres -o yaml > ${SNAPSHOT}

# cassandra
SNAPSHOT=${SNAPSHOT_HOME}/cassandra-$(snapshot_name $INSTANA_VERSION).yaml
$KUBECTL get CassandraDatacenter/cassandra -n instana-cassandra -o yaml > ${SNAPSHOT}

# clickhouse
SNAPSHOT=${SNAPSHOT_HOME}/clickhouse-$(snapshot_name $INSTANA_VERSION).yaml
$KUBECTL get chi/instana -n instana-clickhouse -o yaml > ${SNAPSHOT}

# beeinstana
SNAPSHOT=${SNAPSHOT_HOME}/beeinstana-$(snapshot_name $INSTANA_VERSION).yaml
$KUBECTL get BeeInstana/instance -n beeinstana -o yaml > ${SNAPSHOT}

# core
SNAPSHOT=${SNAPSHOT_HOME}/core-$(snapshot_name $INSTANA_VERSION).yaml
$KUBECTL get core/instana-core -n instana-core -o yaml > ${SNAPSHOT}

# unit
SNAPSHOT=${SNAPSHOT_HOME}/unit-$(snapshot_name $INSTANA_VERSION).yaml
$KUBECTL get unit/${INSTANA_TENANT_NAME}-${INSTANA_UNIT_NAME} -n instana-units -o yaml > ${SNAPSHOT}

