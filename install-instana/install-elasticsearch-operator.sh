#!/bin/bash

# install, upgrade
helm_action=${1:-"install"}

source ../instana.env
source ./help-functions.sh
source ./datastore-images.env

export PATH=.:$(get_bin_home):$PATH

CHART_HOME=$(get_chart_home)
CHART_HOME=${CHART_HOME}/${INSTANA_VERSION}
mkdir -p ${CHART_HOME}

CHART=$CHART_HOME/eck-operator-${ELASTICSEARCH_OPERATOR_CHART_VERSION}.tgz

echo installing elasticsearch operator helm chart $CHART

if test ! -f $CHART; then
   echo helm chart $CHART not found
   exit 1
fi

set -x

elasticsearch_operator_image_tag=`echo $ELASTICSEARCH_OPERATOR_IMG | cut -d : -f 2 -`

helm ${helm_action} elastic-operator -n instana-elasticsearch $CHART \
   --set image.repository=$PRIVATE_REGISTRY/self-hosted-images/3rd-party/operator/elasticsearch \
   --set image.tag=$elasticsearch_operator_image_tag \
   --set imagePullSecrets[0].name="instana-registry" \
   --wait --timeout 60m0s
rc=$?

check_return_code $rc

# todo: check helm status

exit $rc
