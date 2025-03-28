#!/bin/bash

source ./help-functions.sh

helm_version="v3.17.2"
TAR_DARWIN_AMD64="helm-${helm_version}-darwin-amd64.tar.gz"
TAR_DARWIN_ARM64="helm-${helm_version}-darwin-arm64.tar.gz"
TAR_LINUX_AMD64="helm-${helm_version}-linux-amd64.tar.gz"
TAR_LINUX_ARM64="helm-${helm_version}-linux-arm64.tar.gz"

INSTALL_HOME=$(get_make_install_home)
BIN_HOME=$(get_make_bin_home)

machine=`uname -m`
os=`uname -o`

echo uname: `uname -a`
echo machine: $machine, os: $os

function install_helm() {
   local targz=$1
   local os=$2
   local arch=$3

   toolbin="helm"

   find $BIN_HOME -name $toolbin -type f -delete

   mkdir -p "${BIN_HOME}/${os}-${arch}"
   tar zxvf $BIN_HOME/$targz -C $BIN_HOME $os-$arch/helm

   cp $BIN_HOME/$os-$arch/$toolbin $BIN_HOME/$toolbin
}

#
# helm
#

if compare_values $os "Darwin"; then
   if compare_values $machine "x86_64"; then
      install_helm $TAR_DARWIN_AMD64 "darwin" "amd64"
   else
      install_helm $TAR_DARWIN_ARM64 "darwin" "arm64"
   fi

else
   if compare_values $machine "x86_64"; then
      install_helm $TAR_LINUX_AMD64 "linux" "amd64"
   else
      install_helm $TAR_LINUX_ARM64 "linux" "arm64"
   fi
fi

