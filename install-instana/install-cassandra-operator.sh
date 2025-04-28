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

MANIFEST_HOME=$(get_manifest_home)
SCC=$(format_file_path $MANIFEST_HOME $MANIFEST_FILENAME_CASSANDRA_SCC $INSTANA_INSTALL_PROFILE $INSTANA_VERSION)

# deploy scc (openshift only)
if is_platform_ocp $PLATFORM; then
   echo applying cassandra scc $SCC
   $KUBECTL -n instana-cassandra adm policy add-scc-to-user privileged -z cassandra-operator-cass-operator
   $KUBECTL -n instana-cassandra adm policy add-scc-to-user privileged -z default

   #$KUBECTL apply -f $SCC -n instana-cassandra
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

helm ${helm_action} cassandra-operator -n instana-cassandra $CHART \
   --set admissionWebhooks.enabled=true \
   --set securityContext.runAsNonRoot=true \
   --set securityContext.runAsUser=999 \
   --set securityContext.runAsGroup=999 \
   --set image.registry=$PRIVATE_REGISTRY \
   --set image.repository="$cassandra_operator_img_repo" \
   --set image.tag="$cassandra_operator_img_tag" \
   --set imagePullSecrets[0].name="instana-registry" \
   --set appVersion="$CASSANDRA_OPERATOR_CHART_APP_VERSION" \
   --set imageConfig.systemLogger="$PRIVATE_REGISTRY/$CASSANDRA_SYSTEM_LOGGER_IMG" \
   --set imageConfig.k8ssandraClient="$PRIVATE_REGISTRY/$CASSANDRA_K8S_CLIENT_IMG" \
   --wait --timeout 60m0s
rc=$?

check_return_code $rc

# todo: check helm status

exit $rc
