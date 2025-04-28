#!/bin/bash

# "upgrade --no-hooks" version
helm_action=${1:-"install"}

source ../instana.env
source ./help-functions.sh
source ./datastore-images.env

CHART_HOME=$(get_chart_home)
CHART_HOME=${CHART_HOME}/${INSTANA_VERSION}
mkdir -p ${CHART_HOME}

CHART=$CHART_HOME/zookeeper-operator-${ZOOKEEPER_OPERATOR_CHART_VERSION}.tgz

echo installing zookeeper operator helm chart $CHART, INSTANA_VERSION=$INSTANA_VERSION

if test ! -f $CHART; then
   echo helm chart $CHART not found
   exit 1
fi

set -x

zookeeper_operator_img_repo=`echo ${ZOOKEEPER_OPERATOR_IMG} | cut -d : -f 1 -`
zookeeper_operator_img_tag=`echo ${ZOOKEEPER_OPERATOR_IMG} | cut -d : -f 2 -`

zookeeper_hooks_img_repo=`echo ${ZOOKEEPER_KUBECTL_IMG} | cut -d : -f 1 -`
zookeeper_hooks_img_tag=`echo ${ZOOKEEPER_KUBECTL_IMG} | cut -d : -f 2 -`

helm ${helm_action} zookeeper-operator -n instana-zookeeper $CHART \
   --set image.repository=${PRIVATE_REGISTRY}/${zookeeper_operator_img_repo} \
   --set image.tag=${zookeeper_operator_img_tag} \
   --set image.pullPolicy=Always \
   --set hooks.image.repository=${PRIVATE_REGISTRY}/${zookeeper_hooks_img_repo} \
   --set hooks.image.tag=${zookeeper_hooks_img_tag} \
   --set global.imagePullSecrets={"instana-registry"} \
   --wait --timeout 60m0s
rc=$?

check_return_code $rc

exit $rc