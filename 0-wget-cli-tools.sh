#!/bin/bash

source ./help-functions.sh

export PATH=".:$PATH"

reload=${1:-"noreload"}

# instana plugin
echo
echo ... download instana plugin ...
echo
0-wget-instana-plugin.sh $reload
check_return_code $?

# yq
echo
echo ... download yq ...
echo
0-wget-yq.sh $reload
check_return_code $?

# helm
echo
echo ... download helm ...
echo
0-wget-helm.sh $reload
check_return_code $?

