#!/bin/bash

# install, upgrade
helm_action=${1:-"install"}

source ../instana.env
source ./help-functions.sh

CHART_HOME=$(get_chart_home)

CHART=$CHART_HOME/beeinstana-operator-${BEEINSTANA_OPERATOR_CHART_VERSION}.tgz

echo installing beeinstana operator helm chart $CHART

if test ! -f $CHART; then
   echo helm chart $CHART not found
   exit 1
fi

if is_platform_ocp "$PLATFORM"; then
   helm ${helm_action} beeinstana-operator -n beeinstana $CHART \
      --set operator.securityContext.seccompProfile.type=RuntimeDefault \
      --set image.registry=$PRIVATE_REGISTRY \
      --set imagePullSecrets[0].name="instana-registry"
else
   helm ${helm_action} beeinstana-operator -n beeinstana $CHART \
      --set image.registry=$PRIVATE_REGISTRY \
      --set imagePullSecrets[0].name="instana-registry"
fi

