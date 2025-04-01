#!/bin/bash

source ../instana.env
source ./help-functions.sh

set -x

$KUBECTL -n instana-core delete core instana-core
