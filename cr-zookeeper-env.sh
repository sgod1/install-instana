#!/bin/bash

source ../instana.env
source ./datastore-images.env
source ./help-functions.sh
source ./cr-env.sh

template_cr="zookeeper-template.yaml"
env_file="zookeeper-env.yaml"
out_file="gen/zookeeper-env-289.yaml"
profile=${INSTANA_INSTALL_PROFILE:-"template"}

cp $template_cr $out_file

cr_env $template_cr $env_file $out_file $profile
