#!/bin/bash

# install, upgrade
helm_action=${1:-"install"}

source ../instana.env
source ./help-functions.sh
source ./datastore-images.env

CHART_HOME=$(get_chart_home)
MANIFEST_HOME=$(get_manifest_home)

# apply scc
SCC=$MANIFEST_HOME/$MANIFEST_FILENAME_CLICKHOUSE_SCC
echo applying clickhouse scc $SCC

if is_platform_ocp "$PLATFORM" && test ! -f $SCC; then
   echo clickhouse scc $SCC not found
   exit 1
fi

if is_platform_ocp "$PLATFORM"; then
   $KUBECTL apply -f $SCC -n instana-clickhouse
fi

# install clickhouse operator chart
CHART=$CHART_HOME/ibm-clickhouse-operator-${CLICKHOUSE_OPERATOR_CHART_VERSION}.tgz

echo installing clickhouse operator helm chart $CHART

if test ! -f $CHART; then
   echo helm chart $CHART not found
   exit 1
fi

clickhouse_operator_image_tag=`echo $CLICKHOUSE_OPERATOR_IMG | cut -d : -f 2 -`

helm ${helm_action} clickhouse-operator -n instana-clickhouse $CHART \
   --set operator.image.repository=$PRIVATE_REGISTRY/clickhouse-operator \
   --set operator.image.tag=$clickhouse_operator_image_tag \
   --set imagePullSecrets[0].name="instana-registry"
