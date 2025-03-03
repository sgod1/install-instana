#!/bin/bash

source ../instana.env
source ./datastore-images.env
source ./help-functions.sh
source ./cr-env.sh

template_cr="beeinstana-template.yaml"
env_file="beeinstana-env.yaml"
out_file="gen/beeinstana-env-289.yaml"
profile=${INSTANA_INSTALL_PROFILE:-"template"}

cp $template_cr $out_file

cr_env $template_cr $env_file $out_file $profile
