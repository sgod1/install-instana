#!/bin/bash

source ./help-functions.sh

if [[ -f ../installer.env ]]; then source ../installer.env; fi

# extend path
bin_home=$(get_bin_home)
export PATH=".:$bin_home:$PATH"

echo instana install start

if [[ -z $skip_install_init_namespaces ]]; then
   echo initializing namespaces
   init-namespaces.sh; check_return_code $?
else
   echo skip init namespaces
fi

if [[ -z $skip_install_zookeeper ]]; then
   echo installing zookeeper
   install-zookeeper.sh; check_return_code $?
else
   echo skip install zookeeper
fi

if [[ -z $skip_install_kafka ]]; then
echo installing kafka
   install-kafka.sh; check_return_code $?
else
   echo skip install kafka
fi

if [[ -z $skip_install_elasticsearch ]]; then
echo installing elasticsearch
   install-elasticsearch.sh; check_return_code $?
else
   echo skip install elasticsearch
fi

if [[ -z $skip_install_postgres ]]; then
echo installing postgres
   install-postgres.sh; check_return_code $?
else
   echo skip install postgres
fi

if [[ -z $skip_install_cassandra ]]; then
   echo installing cassandra
   install_cassandra.sh; check_return_code $?
else
   echo skip install cassandra
fi

if [[ -z $skip_install_clickhouse ]]; then
echo installing clickhouse
   install-clickhouse.sh; check_return_code $?
else
   echo skip install clickhouse
fi

if [[ -z $skip_install_beeinstana ]]; then
echo installing beeinstana
   install-beeinstana.sh; check_return_code $?
else
   echo skip install beeinstana
fi

if [[ -z $skip_install_instana_operator ]]; then
   echo installing instana operator
   install-instana-operator-apply-cr.sh; check_return_code $?
else
   echo skip install instana operator
fi

if [[ -z $skip_install_instana_core ]]; then
   echo installing instana core
   install-core.sh; check_return_code $?
else
   echo skip install instana core
fi

if [[ -z $skip_install_instana_unit ]]; then
   echo installing instana unit
   install-unit.sh; check_return_code $?
else
   echo skip install instana unit
fi

if [[ -z $skip_install_instana_routes ]]; then
   echo creating routes
   install-create-routes.sh; check_return_code $?
else
   echo skip install instana routes
fi

echo instana install end
