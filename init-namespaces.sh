#!/bin/bash

source ../instana.env
source ./help-functions.sh

INSTALL_HOME=$(get_install_home)

function create_labeled_namespace() {
  ns=$1
  label=$2

  echo creating namespace $ns, label "app.kubernetes.io/name:" $label

  NS_YAML=$INSTALL_HOME/$ns.yaml

cat << EOF > $NS_YAML
apiVersion: v1
kind: Namespace
metadata:
  name: $ns
  labels:
    app.kubernetes.io/name: $ns
EOF

  $KUBECTL apply -f $NS_YAML
  rm $NS_YAML
}

function create_namespace() {
  ns=$1
  label=$2

  if test ! -z $label; then
    create_labeled_namespace $ns $label

  else
    echo creating namespace $ns
    $KUBECTL create namespace $ns
  fi
}

function create_image_pull_secret() {
   ns=$1
   secret_name="instana-registry"

   echo creating image pull secret $secret_name, namespace $ns

   $KUBECTL create secret docker-registry $secret_name \
      --namespace $ns \
      --docker-username=$PRIVATE_REGISTRY_USER \
      --docker-password=$PRIVATE_REGISTRY_PASSWORD \
      --docker-server=$PRIVATE_REGISTRY
}

function init_namespace() {
   ns=$1
   label=$2
   create_namespace $ns $label
   create_image_pull_secret $ns
}

echo
echo initializing namespaces...
echo

init_namespace "instana-zookeeper"
init_namespace "instana-clickhouse"
init_namespace "instana-kafka"
init_namespace "instana-elasticsearch"
init_namespace "instana-postgres"
init_namespace "instana-cassandra"
init_namespace "beeinstana"
init_namespace "instana-operator"
init_namespace "instana-core" "instana-core"
init_namespace "instana-units" "instana-units"
