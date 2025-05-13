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

values_yaml="$(get_install_home)/kafka-operator-values-${INSTANA_VERSION}.yaml"
cat <<EOF > $values_yaml
image:
  registry: $PRIVATE_REGISTRY
  repository: self-hosted-images/3rd-party/operator
  name: strimzi
  tag: ${kafka_operator_img_tag}

  imagePullSecrets:
    - name: "instana-registry"

  kafka:
    image:
      registry: $PRIVATE_REGISTRY
      repository: self-hosted-images/3rd-party/datastore
      name: kafka
      tag: ${kafka_img_tag}

tolerations:
  - effect: NoSchedule
    key: dedicated
    operator: Equal
    value: appng
EOF

helm ${helm_action} kafka-operator -n instana-kafka $CHART -f $values_yaml \
   --wait --timeout 60m0s
rc=$?

check_return_code $rc

exit $rc
