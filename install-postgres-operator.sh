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

# write a function
RUNAS_USER=`${KUBECTL} get namespace instana-postgres -o jsonpath='{.metadata.annotations.openshift\.io\/sa\.scc\.uid-range}' | cut -d/ -f 1`
RUNAS_GROUP=`${KUBECTL} get namespace instana-postgres -o jsonpath='{.metadata.annotations.openshift\.io\/sa\.scc\.uid-range}' | cut -d/ -f 1`

# image pull secret?

if compare_values "$PLATFORM" "$PLATFORM_OCP"
then
   # openshift
   helm install postgres-operator -n instana-postgres $CHART \
     --set image.repository=$PRIVATE_REGISTRY/self-hosted-images/3rd-party/operator/cloudnative-pg \
     --set image.tag=v1.21.1_v0.5.0 \
     --set containerSecurityContext.runAsUser=$RUNAS_USER \
     --set containerSecurityContext.runAsGroup=$RUNAS_GROUP

else
   # k8s
   helm install postgres-operator -n instana-postgres $CHART \
     --set image.repository=$PRIVATE_REGISTRY/self-hosted-images/3rd-party/operator/cloudnative-pg \
     --set image.tag=v1.21.1_v0.5.0 
fi

