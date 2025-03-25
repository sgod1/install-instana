#!/bin/bash

source ../instana.env
source ./help-functions.sh

export PATH="gen/bin:$PATH"

set -x

# delete zookeeper cr in instana-clickhouse namespace
$KUBECTL -n instana-clickhouse delete zk/instana-zookeeper

$KUBECTL -n instana-clickhouse wait --for=delete pod -lrelease=instana-zookeeper --timeout=${WAIT_TIMEOUT:-"600s"}

# uninstall zookeeper operator
helm -n instana-zookeeper uninstall zookeeper-operator

$KUBECTL -n instana-clickhouse wait --for=delete pod -lname=zookeeper-operator
