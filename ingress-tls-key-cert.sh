#!/bin/bash

source ../instana.env
source ./help-functions.sh

profile=${1:-$INSTANA_INSTALL_PROFILE}

./tls-key-cert.sh "ingress" $profile
check_return_code $?
