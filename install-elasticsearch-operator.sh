#!/bin/bash

source ../instana.env
source ./help-functions.sh

CHART_HOME=$(get_chart_home)

CHART=$CHART_HOME/eck-operator-2.9.0.tgz

echo installing elasticsearch operator helm chart $CHART

if test ! -f $CHART; then
   echo helm chart $CHART not found
   exit 1
fi

helm install elastic-operator -n instana-elasticsearch $CHART \
   --set image.repository=$PRIVATE_REGISTRY/self-hosted-images/3rd-party/operator/elasticsearch \
   --set image.tag=2.9.0_v0.11.0
