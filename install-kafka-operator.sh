#!/bin/bash

# install, upgrade
helm_action=${1:-"install"}
INSTANA_VERSION_OVERRIDE=$2

source ../instana.env
source ./help-functions.sh
source ./datastore-images.env

CHART_HOME=$(get_chart_home)

CHART=$CHART_HOME/strimzi-kafka-operator-helm-3-chart-${KAFKA_OPERATOR_CHART_VERSION}.tgz

echo installing kafka operator helm chart $CHART

if test ! -f $CHART; then
   echo helm chart $CHART not found
   exit 1
fi

set -x

kafka_operator_img_tag=`echo ${KAFKA_OPERATOR_IMG} | cut -d : -f 2 -`
kafka_img_tag=`echo ${KAFKA_IMG} | cut -d : -f 2 -`

helm ${helm_action} kafka-operator -n instana-kafka $CHART \
   --set image.registry=$PRIVATE_REGISTRY  \
   --set image.repository=self-hosted-images/3rd-party/operator \
   --set image.name=strimzi  \
   --set image.tag=${kafka_operator_img_tag} \
   --set kafka.image.registry=$PRIVATE_REGISTRY \
   --set kafka.image.repository=self-hosted-images/3rd-party/datastore \
   --set kafka.image.name=kafka \
   --set kafka.image.tag=${kafka_img_tag} \
   --set image.imagePullSecrets[0].name="instana-registry"
