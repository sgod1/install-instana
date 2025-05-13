#!/bin/bash

# "upgrade --no-hooks" version
helm_action=${1:-"install"}

source ../instana.env
source ./help-functions.sh
source ./datastore-images.env

bin_home=$(get_bin_home)
export PATH=.:${bin_home}:$PATH

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

values_yaml="$(get_install_home)/zookeeper-operator-values-${INSTANA_VERSION}.yaml"
cat <<EOF > $values_yaml
image:
  repository: ${PRIVATE_REGISTRY}/${zookeeper_operator_img_repo}
  tag: ${zookeeper_operator_img_tag}
  pullPolicy: Always

hooks:
  image:
    repository: ${PRIVATE_REGISTRY}/${zookeeper_hooks_img_repo}
    tag: ${zookeeper_hooks_img_tag}

global:
  imagePullSecrets:
    - name: instana-registry

tolerations:
  - effect: NoSchedule
    key: dedicated
    operator: Equal
    value: appng
EOF

helm ${helm_action} zookeeper-operator -n instana-zookeeper $CHART -f $values_yaml \
   --wait --timeout 60m0s
rc=$?

check_return_code $rc

exit $rc
