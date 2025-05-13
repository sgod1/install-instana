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

CHART=$CHART_HOME/beeinstana-operator-${BEEINSTANA_OPERATOR_CHART_VERSION}.tgz

echo installing beeinstana operator helm chart $CHART

if test ! -f $CHART; then
   echo helm chart $CHART not found
   exit 1
fi

values_yaml="$(get_install_home)/beeinstana-operator-values-${INSTANA_VERSION}.yaml"

cat <<EOF > $values_yaml
image:
  registry: $PRIVATE_REGISTRY 

imagePullSecrets:
  - name: "instana-registry"

tolerations:
  - effect: NoSchedule
    key: dedicated
    operator: Equal
    value: appng
EOF

if is_platform_ocp "$PLATFORM"; then
   helm ${helm_action} beeinstana-operator -n beeinstana $CHART -f $values_yaml \
      --set operator.securityContext.seccompProfile.type=RuntimeDefault \
      --wait --timeout=60m0s
   rc=$?
else
   helm ${helm_action} beeinstana-operator -n beeinstana $CHART -f $values_yaml \
      --wait --timeout=60m0s
   rc=$?
fi

check_return_code $rc

# todo: check helm status

exit $rc
