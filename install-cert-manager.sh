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
   --set image.repository=$PRIVATE_REGISTRY/jetstack/cert-manager-controller:v1.7.1
   --set webhook.image=$PRIVATE_REGISTRY/jetstack/cert-manager-webhook:v1.7.1
   --set cainjector.image=$PRIVATE_REGISTRY/jetstack/cert-manager-cainjector:v1.7.1
   --set acmesolver.image=$PRIVATE_REGISTRY/jetstack/cert-manager-acmesolver:v1.7.1
   --set startupapicheck.image=$PRIVATE_REGISTRY/jetstack/cert-manager-ctl:v1.7.1
   --set imagePullSecrets[0].name="instana-registry"
