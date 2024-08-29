#!/bin/bash

source ../instana.env
source ./help-functions.sh

# create instana-registry image pool secret


# install cert manager helm chart
echo
echo "installing cert manager helm chart"
echo 

CHART_HOME=$(get_chart_home)

helm install cert-manager $CHART_HOME/cert-manager-v1.13.2.tgz \
   --namespace cert-manager \
   --create-namespace \
   --version v1.13.2 \
   --set installCRDs=true
   --set prometeus.enabled=false \
   --set webhook.timeoutSeconds=4 \
   --set image.repository=$PRIVATE_REGISTRY/jetstack/cert-manager-controller
   --set image.tag=v1.13.2
   --set webhook.image=$PRIVATE_REGISTRY/jetstack/cert-manager-webhook
   --set webhook.image.tag=v1.13.2
   --set cainjector.image=$PRIVATE_REGISTRY/jetstack/cert-manager-cainjector
   --set cainjector.image.tag=v1.13.2
   --set acmesolver.image=$PRIVATE_REGISTRY/jetstack/cert-manager-acmesolver
   --set acmesolver.image.tag=v1.13.2
   --set startupapicheck.image=$PRIVATE_REGISTRY/jetstack/cert-manager-ctl
   --set startupapicheck.image.tag=v1.13.2
   --set imagePullSecrets[0]="instana-registry"
