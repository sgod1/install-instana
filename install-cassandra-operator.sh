#!/bin/bash

source ../instana.env
source ./help-functions.sh

CHART_HOME=$(get_chart_home)
MANIFEST_HOME=$(get_manifest_home)

CHART=$CHART_HOME/cass-operator-0.45.2.tgz

#oc get sa
#NAME                               SECRETS   AGE
#builder                            0         59m
#cass-operator                      0         58m
#cassandra-operator-cass-operator   1         119s
#default                            0         59m
#deployer                           0         59m

#oc create sa cass-operator
#oc create sa cassandra-operator-cass-operator
#oc adm policy add-scc-to-user privileged -z default
#oc adm policy add-scc-to-user privileged -z cass-operator
#oc adm policy add-scc-to-user privileged -z cassandra-operator-cass-operator

#SCC=$MANIFEST_HOME/$MANIFEST_FILENAME_CASSANDRA_SCC
#echo applying cassandra scc $SCC
#
#if test ! -f $SCC; then
#   echo cassandra scc $SCC not found
#   exit 1
#fi
#
#$KUBECTL apply -f $SCC -n instana-cassandra

echo installing cassandra operator helm chart $CHART

if test ! -f $CHART; then
   echo helm chart $CHART not found
   exit 1
fi

#| podSecurityContext | object | `{}` | PodSecurityContext for the cass-operator pod. See: https://kubernetes.io/docs/tasks/configure-pod-container/security-context/ |
#| securityContext.runAsNonRoot | bool | `true` | Run cass-operator container as non-root user |
#| securityContext.runAsGroup | int | `65534` | Group for the user running the cass-operator container / process |
#| securityContext.runAsUser | int | `65534` | User for running the cass-operator container / process |
#| securityContext.readOnlyRootFilesystem | bool | `true` | Run cass-operator container having read-only root file system permissions. |

#   --set securityContext.runAsGroup=999 \
#   --set securityContext.runAsUser=999 \

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
   --set imageConfig.k8ssandraClient="$PRIVATE_REGISTRY/self-hosted-images/3rd-party/datastore/k8ssandra-client:0.2.2_v0.3.0"
