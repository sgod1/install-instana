#!/bin/bash

source ../instana.env
source ./help-functions.sh

bin_home=$(get_bin_home)
PATH=".:$bin_home:$PATH"

set -x

echo delete beeinstana instance
$KUBECTL delete beeinstana instance

echo uninstall beeinstana operator
helm uninstall beeinstana-operator -n beeinstana
