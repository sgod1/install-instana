#!/bin/bash


source ../instana.env
source ./help-functions.sh

CHART_HOME=$(get_chart_home)

CHART=$CHART_HOME/beeinstana-operator-v1.58.0.tgz

echo installing beeinstana operator helm chart $CHART

if test ! -f $CHART; then
   echo helm chart $CHART not found
   exit 1
fi

if is_platform_ocp "$PLATFORM"; then
   helm install beeinstana-operator -n beeinstana $CHART \
      --set operator.securityContext.seccompProfile.type=RuntimeDefault \
      --set image.registry=$PRIVATE_REGISTRY \
      --set imagePullSecrets[0].name="instana-registry"
else
   helm install beeinstana-operator -n beeinstana $CHART \
      --set image.registry=$PRIVATE_REGISTRY \
      --set imagePullSecrets[0].name="instana-registry"
fi

