#!/bin/bash

source ./help-functions.sh

export PATH=".:$PATH"

reload=${1:-"noreload"}

# instana plugin
echo ... download instana plugin ...
0-wget-instana-plugin.sh $reload
check_return_code $?

# yq
echo ... download yq ...
0-wget-yq.sh $reload
check_return_code $?

# helm
echo ... download helm ...
0-wget-helm.sh $reload
check_return_code $?

# kubectl
echo ... download kubectl ...
0-wget-kubectl.sh $reload
check_return_code $?

