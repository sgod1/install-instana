#!/bin/bash

source ../instana.env
source ./help-functions.sh

REGISTRY_OVERWRITE=$1
REGISTRY=${REGISTRY_OVERWRITE:-$PRIVATE_REGISTRY}

CHART_HOME=$(get_chart_home)

CHART=$CHART_HOME/cert-manager-v1.13.2.tgz

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
   --version v1.13.2 \
   --set imagePullSecrets[0]="instana-registry" \
   --set global.leaderElection.namespace=cert-manager \
   --set installCRDs=true \
   --set prometeus.enabled=false \
   --set webhook.timeoutSeconds=4 \
   --set image.repository=$REGISTRY/jetstack/cert-manager-controller \
   --set image.tag=v1.13.2 \
   --set image.pullPolicy=Always \
   --set webhook.image.repository=$REGISTRY/jetstack/cert-manager-webhook \
   --set webhook.image.tag=v1.13.2 \
   --set webhook.image.pullPolicy=Always \
   --set cainjector.image.repository=$REGISTRY/jetstack/cert-manager-cainjector \
   --set cainjector.image.tag=v1.13.2 \
   --set cainjector.image.pullPolicy=Always \
   --set acmesolver.image.repository=$REGISTRY/jetstack/cert-manager-acmesolver \
   --set acmesolver.image.tag=v1.13.2 \
   --set acmesolver.image.pullPolicy=Always \
   --set startupapicheck.enabled=false \
   --set startupapicheck.image.repository=$REGISTRY/jetstack/cert-manager-ctl \
   --set startupapicheck.image.tag=v1.13.2 \
   --set startupapicheck.image.pullPolicy=Always \
   --set resources.requests.cpu=500m \
   --set resources.requests.memory=512Mi \
   --set cainjector.resources.requests.cpu=500m \
   --set cainjector.resources.requests.memory=512Mi \
   --set webhook.resources.requests.cpu=500m \
   --set webhook.resources.requests.memory=512Mi
