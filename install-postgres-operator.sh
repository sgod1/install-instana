#!/bin/bash

source ../instana.env
source ./help-functions.sh
source ./datastore-images.env

CHART_HOME=$(get_chart_home)

CHART=$CHART_HOME/cloudnative-pg-${POSTGRES_OPERATOR_CHART_VERSION}.tgz

echo installing postgres operator helm chart $CHART

if test ! -f $CHART; then
   echo helm chart $CHART not found
   exit 1
fi

postgres_operator_img_repo=`cat ${POSTGRES_OPERATOR_IMG} | cut -d : -f 1 -`
postgres_operator_img_tag=`cat ${POSTGRES_OPERATOR_IMG} | cut -d : -f 2 -`

if is_platform_ocp "$PLATFORM"; then
   #
   # openshift
   #

   # uid range
   uid_range_start=`$KUBECTL get namespace instana-postgres -o jsonpath='{.metadata.annotations.openshift\.io\/sa\.scc\.uid-range}' | cut -d/ -f 1`

   helm install postgres-operator -n instana-postgres $CHART \
     --set image.repository=$PRIVATE_REGISTRY/${postgres_operator_img_repo} \
     --set image.tag=${postgres_operator_img_tag} \
     --set imagePullSecrets[0].name="instana-registry" \
     --set containerSecurityContext.runAsUser=$uid_range_start \
     --set containerSecurityContext.runAsGroup=$uid_range_start

else
   # k8s
   helm install postgres-operator -n instana-postgres $CHART \
     --set image.repository=$PRIVATE_REGISTRY/${postgres_operator_img_repo} \
     --set image.tag=${postgres_operator_img_tag} \
     --set imagePullSecrets[0].name="instana-registry"
fi

