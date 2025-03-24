#!/bin/bash

source ../instana.env
source ./help-functions.sh

select_namespace=${1:-""}
select_label=${2:-""}

INSTALL_HOME=$(get_install_home)

function create_namespace() {
  local ns=$1
  local psa_label=$2

  echo ... create namespace $ns, psa label ${psa_label:-"no label"}, platform $PLATFORM

  NS_YAML="$INSTALL_HOME/ns-$ns.yaml"

  # write out namespace
cat << EOF > $NS_YAML
apiVersion: v1
kind: Namespace
metadata:
  name: $ns

  labels:
    app.kubernetes.io/name: $ns

EOF

  if test $psa_label; then
cat << EOF >> $NS_YAML
    #
    # set admission-control mode (enforce) and pss level (privileged/baseline/restricted) for pod security
    # psa will check pod request for conformance with pss level
    #
    pod-security.kubernetes.io/enforce: $psa_label
    pod-security.kubernetes.io/enforce-version: latest
EOF
  fi

  $KUBECTL apply -f $NS_YAML
  check_return_code $?

  $KUBECTL wait --for=jsonpath='{.status.phase}'=Active ns/$ns
  check_return_code $?

  echo ... namespace $ns status Active ...
}

function create_image_pull_secret() {
   local ns=$1
   local secret_name="instana-registry"
   local rc

   echo ... get image pull secret $secret_name, namespace $ns
   $KUBECTL get secret $secret_name --namespace $ns 2>/dev/null
   rc=$?

   if [[ $rc == 0 ]]; then
      echo ... deleting image pull secret $secret_name, namespace $ns
      $KUBECTL delete secret $secret_name --namespace $ns; rc=$?
      check_return_code $rc

      #$KUBECTL wait --for=delete secret/$secret_name --namespace $ns
      #check_return_code $rc
   fi

   echo ... creating image pull secret $secret_name, namespace $ns
   $KUBECTL create secret docker-registry $secret_name \
      --namespace $ns \
      --docker-username=$PRIVATE_REGISTRY_USER \
      --docker-password=$PRIVATE_REGISTRY_PASSWORD \
      --docker-server=$PRIVATE_DOCKER_SERVER;
   rc=$?
   check_return_code $rc

   #$KUBECTL wait --for=create secret/$secret_name --namespace $ns
   #check_return_code $rc
}

function init_namespace() {
   local ns=$1
   local label=$2

   echo
   echo ... namespace $ns, label ${label:-"no label"}

   create_namespace $ns $label
   create_image_pull_secret $ns
}

#
# main
#

echo
echo ... initializing namespaces
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
init_namespace "instana-core"
init_namespace "instana-units"

echo
echo ... namespaces initialized
echo

fi

