#!/bin/bash

# install, upgrade or "upgrade --no-hooks"
helm_action=${1:-"install"}

source ../instana.env
source ./help-functions.sh
source ./datastore-images.env

export PATH=.:$(get_bin_home):$PATH

CHART_HOME=$(get_chart_home)
CHART_HOME=${CHART_HOME}/${INSTANA_VERSION}
mkdir -p ${CHART_HOME}

CHART=$CHART_HOME/strimzi-kafka-operator-helm-3-chart-${KAFKA_OPERATOR_CHART_VERSION}.tgz

echo installing kafka operator helm chart $CHART, INSTANA_VERSION=$INSTANA_VERSION

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
   --set image.imagePullSecrets[0].name="instana-registry" \
   --wait --timeout 60m0s
rc=$?

check_return_code $rc

exit $rc
