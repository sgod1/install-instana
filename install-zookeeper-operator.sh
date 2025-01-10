#!/bin/bash

source ../instana.env
source ./help-functions.sh
source ./datastore-images.env

CHART_HOME=$(get_chart_home)

CHART=$CHART_HOME/zookeeper-operator-${ZOOKEEPER_OPERATOR_CHART_VERSION}.tgz

echo installing zookeeper operator helm chart $CHART

if test ! -f $CHART; then
   echo helm chart $CHART not found
   exit 1
fi

set -x

zookeeper_operator_img_repo=`echo ${ZOOKEEPER_OPERATOR_IMG} | cut -d : -f 1 -`
zookeeper_operator_img_tag=`echo ${ZOOKEEPER_OPERATOR_IMG} | cut -d : -f 2 -`

zookeeper_hooks_img_repo=`echo ${ZOOKEEPER_KUBECTL_IMG} | cut -d : -f 1 -`

helm install zookeeper-operator -n instana-zookeeper $CHART \
   --set image.repository=${PRIVATE_REGISTRY}/${zookeeper_operator_img_repo} \
   --set image.tag=${zookeeper_operator_img_tag} \
   --set hooks.image.repository=${PRIVATE_REGISTRY}/${zookeeper_hooks_img_repo} \
   --set global.imagePullSecrets={"instana-registry"}
