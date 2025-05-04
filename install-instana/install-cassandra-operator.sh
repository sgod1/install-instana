#!/bin/bash

source ../instana.env
source ./install.env
source ./help-functions.sh
source ./datastore-images.env; check_return_code $?

# install, upgrade
helm_action=${1:-"install"}

bin_home=$(get_bin_home)
PATH=".:$bin_home:$PATH"

CHART_HOME=$(get_chart_home)
CHART_HOME=${CHART_HOME}/${INSTANA_VERSION}
mkdir -p ${CHART_HOME}

CHART=$CHART_HOME/cass-operator-${CASSANDRA_OPERATOR_CHART_VERSION}.tgz

# deploy scc (openshift only)
if is_platform_ocp $PLATFORM; then

   MANIFEST_HOME=$(get_manifest_home)
   SCC=$(format_file_path $MANIFEST_HOME $MANIFEST_FILENAME_CASSANDRA_SCC $INSTANA_INSTALL_PROFILE $INSTANA_VERSION)

   if [[ ! -f $SCC ]]; then
      echo "cassandra scc $SCC not found"
      exit 1
   fi

   echo applying cassandra scc $SCC
   $KUBECTL apply -f $SCC -n instana-cassandra
   check_return_code $?

   #$KUBECTL adm policy add-scc-to-user privileged -z default -n instana-cassandra
   #check_return_code $?
   #$KUBECTL adm policy add-scc-to-user privileged -z cassandra-operator-cass-operator -n instana-cassandra
   #check_return_code $?
fi

# check for chart
if test ! -f $CHART; then
   echo helm chart $CHART not found
   exit 1
fi

echo ""
echo installing cassandra operator helm chart $CHART
echo ""

set -x

cassandra_operator_img_repo=`echo $CASSANDRA_OPERATOR_IMG | cut -d : -f 1 -`
cassandra_operator_img_tag=`echo $CASSANDRA_OPERATOR_IMG | cut -d : -f 2 -`

#securityContext:
#  runAsNonRoot: true
#admissionWebhooks:
#  enabled: true

values_yaml="$(get_install_home)/cassandra-operator-values-${INSTANA_VERSION}.yaml"

cat <<EOF > $values_yaml
securityContext:
  runAsUser: 999
  runAsGroup: 999

image:
  registry: $PRIVATE_REGISTRY
  repository: "$cassandra_operator_img_repo"
  tag: "$cassandra_operator_img_tag"

imagePullSecrets:
  - name: "instana-registry"

appVersion: "$CASSANDRA_OPERATOR_CHART_APP_VERSION"

imageConfig:
  systemLogger: "$PRIVATE_REGISTRY/$CASSANDRA_SYSTEM_LOGGER_IMG"
  k8ssandraClient: "$PRIVATE_REGISTRY/$CASSANDRA_K8S_CLIENT_IMG"
EOF

helm ${helm_action} cassandra-operator -n instana-cassandra $CHART -f $values_yaml \
   --wait --timeout 60m0s
rc=$?

check_return_code $rc

# todo: check helm status

exit $rc
