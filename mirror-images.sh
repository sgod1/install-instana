#!/bin/bash

source ../instana.env
source ./help-functions.sh

mirror_home=$(get_mirror_home $INSTANA_VERSION)

function run_mirror_script() {
   local script_name=$1
   local currdir=`pwd`;
   cd $mirror_home
   `pwd`/$script_name
   local rc=$?
   cd $currdir
   return $rc
}

echo mirror backend images, mirror home ... $mirror_home
run_mirror_script backend-pull-images.sh
check_return_code $?
run_mirror_script backend-tag-images.sh
check_return_code $?
run_mirror_script backend-push-images.sh
check_return_code $?

echo mirror cert-manager images, mirror home ... $mirror_home
run_mirror_script cert-manager-pull-images.sh
check_return_code $?
run_mirror_script cert-manager-tag-images.sh
check_return_code $?
run_mirror_script cert-manager-push-images.sh
check_return_code $?

echo mirror datastore images, mirror home ... $mirror_home
run_mirror_script datastore-pull-images.sh
check_return_code $?
run_mirror_script datastore-tag-images.sh
check_return_code $?
run_mirror_script datastore-push-images.sh
check_return_code $?

echo mirror instana-operator images, mirror home ... $mirror_home
run_mirror_script instana-operator-pull-images.sh
check_return_code $?
run_mirror_script instana-operator-tag-images.sh
check_return_code $?
run_mirror_script instana-operator-push-images.sh
check_return_code $?
