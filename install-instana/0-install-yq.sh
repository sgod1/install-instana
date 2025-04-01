#!/bin/bash

source ./help-functions.sh

INSTALL_HOME=$(get_make_install_home)
BIN_HOME=$(get_make_bin_home)

machine=`uname -m`
os=`uname -o`

echo uname: `uname -a`
echo machine: $machine, os: $os

#
# yq
#

yqbin=""

if [[ $os == "Darwin" ]]; then
   if [[ $machine == "x86_64" ]]; then
      yqbin="yq_darwin_amd64"
   else
      yqbin="yq_darwin_arm64"
   fi

else
   if [[ $machine == "x86_64" ]]; then
      yqbin="yq_linux_amd64"
   else
      yqbin="yq_linux_arm64"
   fi
fi

if [[ -z $yqbin ]]; then
   echo yq binary name undefined, uname: `uname -a`
   exit 1
fi

if [[ ! -f $BIN_HOME/$yqbin ]]; then
   echo yq binary file $BIN_HOME/$yq_tar not found
   exit 1
fi

echo ""
echo installing $yqbin to $BIN_HOME/yq
echo ""

cp $BIN_HOME/$yqbin $BIN_HOME/yq
chmod +x $BIN_HOME/yq
