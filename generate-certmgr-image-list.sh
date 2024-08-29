#!/bin/bash

source ../instana.env
source ./help-functions.sh

MIRROR_HOME=$(get_make_mirror_home)

echo writing cert manager image list to $MIRROR_HOME/$CERT_MGR_IMAGE_LIST_FILE

echo "
quay.io/jetstack/cert-manager-cainjector:v1.13.2
quay.io/jetstack/cert-manager-controller:v1.13.2
quay.io/jetstack/cert-manager-webhook:v1.13.2
quay.io/jetstack/cert-manager-acmesolver:v1.13.2
quay.io/jetstack/cert-manager-ctl:v1.13.2
" > $MIRROR_HOME/$CERT_MGR_IMAGE_LIST_FILE
