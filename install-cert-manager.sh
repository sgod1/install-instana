#!/bin/bash

source ../instana.env
source ./help-functions.sh

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

helm install cert-manager $CHART
   --namespace cert-manager \
   --create-namespace \
   --version v1.13.2 \
   --set installCRDs=true
   --set prometeus.enabled=false \
   --set webhook.timeoutSeconds=4 \
   --set image.repository=$PRIVATE_REGISTRY/jetstack/cert-manager-controller
   --set image.tag=v1.13.2
   --set webhook.image.repository=$PRIVATE_REGISTRY/jetstack/cert-manager-webhook
   --set webhook.image.tag=v1.13.2
   --set cainjector.image.repository=$PRIVATE_REGISTRY/jetstack/cert-manager-cainjector
   --set cainjector.image.tag=v1.13.2
   --set acmesolver.image.repository=$PRIVATE_REGISTRY/jetstack/cert-manager-acmesolver
   --set acmesolver.image.tag=v1.13.2
   --set startupapicheck.image.repository=$PRIVATE_REGISTRY/jetstack/cert-manager-ctl
   --set startupapicheck.image.tag=v1.13.2
   --set imagePullSecrets[0]="instana-registry"
