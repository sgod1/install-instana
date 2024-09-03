#!/bin/bash

source ../instana.env
source ./help-functions.sh

CHART_HOME=$(get_chart_home)

CHART=$CHART_HOME/cloudnative-pg-0.20.0.tgz

echo installing postgres operator helm chart $CHART

if test ! -f $CHART; then
   echo helm chart $CHART not found
   exit 1
fi

if is_platform_ocp "$PLATFORM"; then
   #
   # openshift
   #

   # uid range
   uid_range_start=`$KUBECTL get namespace instana-postgres -o jsonpath='{.metadata.annotations.openshift\.io\/sa\.scc\.uid-range}' | cut -d/ -f 1`

   helm install postgres-operator -n instana-postgres $CHART \
     --set image.repository=$PRIVATE_REGISTRY/self-hosted-images/3rd-party/operator/cloudnative-pg \
     --set image.tag=v1.21.1_v0.5.0 \
     --set imagePullSecrets[0]="instana-registry" \
     --set containerSecurityContext.runAsUser=$uid_range_start \
     --set containerSecurityContext.runAsGroup=$uid_range_start

else
   # k8s
   helm install postgres-operator -n instana-postgres $CHART \
     --set image.repository=$PRIVATE_REGISTRY/self-hosted-images/3rd-party/operator/cloudnative-pg \
     --set image.tag=v1.21.1_v0.5.0 \
     --set imagePullSecrets[0]="instana-registry"
fi

