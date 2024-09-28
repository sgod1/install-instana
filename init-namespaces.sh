#!/bin/bash

source ../instana.env
source ./help-functions.sh

select_namespace=${1:-""}
select_label=${2:-""}

INSTALL_HOME=$(get_install_home)

function create_psa_labeled_namespace() {
  ns=$1
  label=$2

  NS_YAML="$INSTALL_HOME/ns-$ns.yaml"

  if ! is_platform_ocp "$PLATFORM"; then
     echo creating namespace $ns, label "pod-security.kubernetes.io/enforce:" $label
  else
     echo creating namespace $ns
  fi

  # write out namespace
cat << EOF > $NS_YAML
apiVersion: v1
kind: Namespace
metadata:
  name: $ns

EOF

  # write out psa label
  if ! is_platform_ocp "$PLATFORM"; then
cat << EOF >> $NS_YAML
  labels:
    #
    # set admission-control mode (enforce) and pss level (privileged/baseline/restricted) for pod security
    # psa will check pod request for conformance with pss level
    #
    pod-security.kubernetes.io/enforce: $label
    pod-security.kubernetes.io/enforce-version: latest
EOF
  fi

  $KUBECTL apply -f $NS_YAML
  rm $NS_YAML
}

function create_labeled_namespace() {
  ns=$1
  label=$2

  echo creating namespace $ns, label "app.kubernetes.io/name:" $label

  NS_YAML="$INSTALL_HOME/ns-$ns.yaml"

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

  if compare_values "$label" "privileged"; then
    create_psa_labeled_namespace $ns $label

  elif compare_values "$label" "baseline"; then
    create_psa_labeled_namespace $ns $label

  elif compare_values "$label" "restricted"; then
    create_psa_labeled_namespace $ns $label

  elif test ! -z "$label"; then
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
      --docker-server=$PRIVATE_DOCKER_SERVER
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

if test ! -z $select_namespace; then
init_namespace $select_namespace $select_label
else
init_namespace "cert-manager" ${K8S_PSA_LABEL:-"privileged"}
init_namespace "instana-zookeeper" ${K8S_PSA_LABEL:-"privileged"}
init_namespace "instana-kafka" ${K8S_PSA_LABEL:-"privileged"}
init_namespace "instana-elasticsearch" ${K8S_PSA_LABEL:-"privileged"}
init_namespace "instana-postgres"
init_namespace "instana-cassandra" ${K8S_PSA_LABEL:-"privileged"}
init_namespace "instana-clickhouse"
init_namespace "beeinstana"
init_namespace "instana-operator"
init_namespace "instana-core" "instana-core"
init_namespace "instana-units" "instana-units"
fi

