#!/bin/bash

source ./help-functions.sh

kv="v1.32.3"

#kv=curl -L -s https://dl.k8s.io/release/stable.txt

bin_home=$(get_make_bin_home)

#set -x

function init_dir() {
   local os=$1; local arch=$2; local osa="${os}-${arch}"
   mkdir -p $bin_home/"${osa}" && find $bin_home/"${osa}" -type f -name "kubectl*" -delete && if [[ $? > 0 ]]; then exit $?; fi
}

function load() {
  local os=$1; local arch=$2; local osa="${os}-${arch}"
  if test -f $bin_home/"${osa}"/kubectl && test $reload_flag = "noreload"; then
     echo kubectl already downloaded to $bin_home/"${osa}"
  else
     init_dir ${os} ${arch} && wget -P $bin_home/"${osa}" "https://dl.k8s.io/release/${kv}/bin/${os}/${arch}/kubectl" && if [[ $? > 0 ]]; then exit $?; fi
  fi
}

#
# main
#

# reload
reload_flag=${1:-"noreload"}

load "linux" "amd64" 
load "linux" "arm64"
load "darwin" "amd64"
load "darwin" "arm64"

