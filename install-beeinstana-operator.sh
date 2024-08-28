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

helm install beeinstana-operator -n beeinstana $CHART \
   --set operator.securityContext.seccompProfile.type=RuntimeDefault \
   --set image.registry=$PRIVATE_REGISTRY \
   --set imagePullSecrets[0].name="instana-registry"

# openshift
#helm install beeinstana-operator ./beeinstana-operator-v1.50.0.tgz --namespace=beeinstana \

# k8s
#helm install beeinstana-operator ./beeinstana-operator-v1.50.0.tgz --namespace=beeinstana 
#--set image.registry=<internal-image-registry>

