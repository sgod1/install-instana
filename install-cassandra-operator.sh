#!/bin/bash

source ../instana.env
source ./help-functions.sh

CHART_HOME=$(get_chart_home)
MANIFEST_HOME=$(get_manifest_home)

CHART=$CHART_HOME/cass-operator-0.45.2.tgz

SCC=$MANIFEST_HOME/$MANIFEST_FILENAME_CASSANDRA_SCC

if is_platform_ocp $PLATFORM && test ! -f $SCC; then
   echo cassandra scc $SCC not found
   exit 1
fi

if is_platform_ocp $PLATFORM; then
   echo applying cassandra scc $SCC
   $KUBECTL apply -f $SCC -n instana-cassandra
fi

echo installing cassandra operator helm chart $CHART

if test ! -f $CHART; then
   echo helm chart $CHART not found
   exit 1
fi

helm install cassandra-operator -n instana-cassandra $CHART \
   --set securityContext.runAsNonRoot=true \
   --set securityContext.runAsUser=999 \
   --set securityContext.runAsGroup=999 \
   --set image.registry=$PRIVATE_REGISTRY \
   --set image.repository="self-hosted-images/3rd-party/operator/cass-operator" \
   --set image.tag="1.18.2_v0.12.0" \
   --set imagePullSecrets[0].name="instana-registry" \
   --set appVersion="1.18.2" \
   --set imageConfig.systemLogger="$PRIVATE_REGISTRY/self-hosted-images/3rd-party/datastore/system-logger:1.18.2_v0.3.0" \
   --set imageConfig.k8ssandraClient="$PRIVATE_REGISTRY/self-hosted-images/3rd-party/datastore/k8ssandra-client:0.2.2_v0.3.0" \
   --set imageConfig.configBuilder="$PRIVATE_REGISTRY/datastax/cass-config-builder:1.0-ubi7"
