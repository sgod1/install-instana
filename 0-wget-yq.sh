#!/bin/bash

source ./help-functions.sh

BIN_HOME=$(get_make_bin_home)

function yqdelete() {
   local yqbin=$1
   find $BIN_HOME -name $yqbin -delete
}

function yqdownload() {
   local yqbin=$1

   if [[ -f ./cli/$yqbin ]]; then
      echo copying yq $yqbin from cli to gen/bin
      cp ./cli/$yqbin $BIN_HOME/$yqbin

   elif [[ ! -f $BIN_HOME/$yqbin ]]; then
      curl -L --output-dir $BIN_HOME https://github.com/mikefarah/yq/releases/latest/download/$yqbin -o $yqbin
      check_return_code $?
   else
      echo yq binary $yqbin already downloaded to $BIN_HOME
   fi
}

#
# main
#

reload=${1:-"noreload"}

if [[ $reload == "reload" ]]; then
   yqdelete yq_linux_amd64
   yqdelete yq_linux_arm64
   yqdelete yq_darwin_amd64
   yqdelete yq_darwin_arm64
fi

yqdownload yq_linux_amd64; check_return_code $?
yqdownload yq_linux_arm64; check_return_code $?
yqdownload yq_darwin_amd64; check_return_code $?
yqdownload yq_darwin_arm64; check_return_code $?
