#!/bin/bash

source ../instana.env
source ./help-functions.sh

CHART_HOME=$(get_chart_home)

CHART=$CHART_HOME/zookeeper-operator-0.2.15.tgz

echo installing zookeeper operator helm chart $CHART

if test ! -f $CHART; then
   echo helm chart $CHART not found
   exit 1
fi

set -x

helm install zookeeper-operator -n instana-zookeeper $CHART \
   --set image.repository=$PRIVATE_REGISTRY/self-hosted-images/3rd-party/operator/zookeeper \
   --set image.tag=0.2.15_v0.11.0 \
   --set global.imagePullSecrets={"instana-registry"}
