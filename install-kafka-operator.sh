#!/bin/bash

source ../instana.env
source ./help-functions.sh

CHART_HOME=$(get_chart_home)

CHART=$CHART_HOME/strimzi-kafka-operator-helm-3-chart-0.41.0.tgz

echo installing kafka operator helm chart $CHART

if test ! -f $CHART; then
   echo helm chart $CHART not found
   exit 1
fi

helm install kafka-operator -n instana-kafka $CHART \
   --set image.registry=$PRIVATE_REGISTRY  \
   --set image.repository=self-hosted-images/3rd-party/operator \
   --set image.name=strimzi  \
   --set image.tag=0.41.0_v0.9.0 \
   --set kafka.image.registry=$PRIVATE_REGISTRY \
   --set kafka.image.repository=self-hosted-images/3rd-party/datastore \
   --set kafka.image.name=kafka \
   --set kafka.image.tag=0.41.0-kafka-3.6.2_v0.7.0
