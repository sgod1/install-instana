#!/bin/bash

source ../instana.env
source ./help-functions.sh
source ./certmgr-images.env

REGISTRY_OVERWRITE=$1
REGISTRY=${REGISTRY_OVERWRITE:-$PRIVATE_REGISTRY}

CHART_HOME=$(get_chart_home)
CHART_HOME=${CHART_HOME}/${INSTANA_VERSION}
mkdir -p ${CHART_HOME}

CHART=$CHART_HOME/cert-manager-${CERTMGR_OPERATOR_CHART_VERSION}.tgz

# install cert manager helm chart
echo
echo "installing cert manager helm chart $CHART"
echo 

if test ! -f $CHART; then
   echo cert manager helm chart $CHART not found
   exit 1
fi

# startupapicheck.enabled is set to false
# gke:
# --set global.leaderElection.namespace=cert-manager \

set -x

helm install cert-manager $CHART \
   --namespace cert-manager \
   --version ${CERTMGR_VERSION} \
   --set imagePullSecrets[0]="instana-registry" \
   --set global.leaderElection.namespace=cert-manager \
   --set installCRDs=true \
   --set prometeus.enabled=false \
   --set webhook.timeoutSeconds=4 \
   --set image.repository=$REGISTRY/jetstack/cert-manager-controller \
   --set image.tag=${CERTMGR_VERSION} \
   --set image.pullPolicy=Always \
   --set webhook.image.repository=$REGISTRY/jetstack/cert-manager-webhook \
   --set webhook.image.tag=${CERTMGR_VERSION} \
   --set webhook.image.pullPolicy=Always \
   --set cainjector.image.repository=$REGISTRY/jetstack/cert-manager-cainjector \
   --set cainjector.image.tag=${CERTMGR_VERSION} \
   --set cainjector.image.pullPolicy=Always \
   --set acmesolver.image.repository=$REGISTRY/jetstack/cert-manager-acmesolver \
   --set acmesolver.image.tag=${CERTMGR_VERSION} \
   --set acmesolver.image.pullPolicy=Always \
   --set startupapicheck.enabled=false \
   --set startupapicheck.image.repository=$REGISTRY/jetstack/cert-manager-ctl \
   --set startupapicheck.image.tag=${CERTMGR_VERSION} \
   --set startupapicheck.image.pullPolicy=Always \
   --set resources.requests.cpu=500m \
   --set resources.requests.memory=512Mi \
   --set cainjector.resources.requests.cpu=500m \
   --set cainjector.resources.requests.memory=512Mi \
   --set webhook.resources.requests.cpu=500m \
   --set webhook.resources.requests.memory=512Mi

