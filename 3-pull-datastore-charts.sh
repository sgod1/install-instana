#!/bin/bash -x

source ../instana.env

source ./help-functions.sh

CHART_HOME=$(get_make_chart_home)

helm repo add instana https://helm.instana.io/artifactory/rel-helm-customer-virtual --username _ --password $DOWNLOAD_KEY

helm repo update

#
# zookeeper operator
# --set image.repository=$PRIVATE_REGISTRY/self-hosted-images/3rd-party/operator/zookeeper 
# --set image.tag=0.2.15_v0.11.0
#  zookeeper-operator-0.2.15.tgz
#
helm pull instana/zookeeper-operator --version=0.2.15 -d $CHART_HOME

#
# kafka operator
# -n instana-kafka 
# --set image.registry=artifact-public.instana.io 
# --set image.repository=self-hosted-images/3rd-party/operator 
# --set image.name=strimzi 
# --set image.tag=0.41.0_v0.9.0 
# --set image.imagePullSecrets[0].name="instana-registry" 
# --set kafka.image.registry=artifact-public.instana.io 
# --set kafka.image.repository=self-hosted-images/3rd-party/datastore 
# --set kafka.image.name=kafka 
# --set kafka.image.tag=0.41.0-kafka-3.6.2_v0.7.0
#
helm pull instana/strimzi-kafka-operator --version=0.41.0 -d $CHART_HOME

#
# elasticsearch
# -n instana-elasticsearch
# --set image.repository=artifact-public.instana.io/self-hosted-images/3rd-party/operator/elasticsearch 
# --set image.tag=2.9.0_v0.11.0 
# --set imagePullSecrets[0].name="instana-registry"
#
helm pull instana/eck-operator --version=2.9.0 -d $CHART_HOME

#
# postgres
# --set image.repository=artifact-public.instana.io/self-hosted-images/3rd-party/operator/cloudnative-pg 
# --set image.tag=v1.21.1_v0.5.0 
# --set imagePullSecrets[0].name=instana-registry 
# --set containerSecurityContext.runAsUser=<UID from namespace> 
# --set containerSecurityContext.runAsGroup=<UID from namespace> 
# -n instana-postgres
#
# ? helm pull instana/cloudnative-pg --version=0.21.1 
#
helm pull instana/cloudnative-pg --version=0.20.0 -d $CHART_HOME

#
# cassandra
# -n instana-cassandra 
# --set securityContext.runAsGroup=999 
# --set securityContext.runAsUser=999 
# --set image.registry=artifact-public.instana.io 
# --set image.repository=self-hosted-images/3rd-party/operator/cass-operator 
# --set image.tag=1.18.2_v0.12.0 
# --set imagePullSecrets[0].name=instana-registry 
# --set appVersion=1.18.2 
# --set imageConfig.systemLogger=artifact-public.instana.io/self-hosted-images/3rd-party/datastore/system-logger:1.18.2_v0.3.0 
# --set imageConfig.k8ssandraClient=artifact-public.instana.io/self-hosted-images/3rd-party/datastore/k8ssandra-client:0.2.2_v0.3.0
#
helm pull instana/cass-operator --version=0.45.2 -d $CHART_HOME

#
# clickhouse
# -n instana-clickhouse 
# --set operator.image.repository=artifact-public.instana.io/clickhouse-operator 
# --set operator.image.tag=v0.1.2 
# --set imagePullSecrets[0].name="instana-registry"
#
helm pull instana/ibm-clickhouse-operator --version=v0.1.2 -d $CHART_HOME

#
# beeinstana
#
helm pull instana/beeinstana-operator --version=v1.58.0 -d $CHART_HOME

#
# cert-manager
#
helm pull instana/cert-manager --version=v1.13.2 -d $CHART_HOME
