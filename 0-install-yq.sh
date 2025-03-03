#!/bin/bash

source ./help-functions.sh

INSTALL_HOME=$(get_make_install_home)
BIN_HOME=$(get_make_bin_home)

machine=`uname -m`
os=`uname -o`

echo uname: `uname -a`
echo machine: $machine, os: $os

function install_tar() {
   targz=$1
   toolbin=$2

   ostoolbin=`echo $targz | cut -d "." -f 1`

   if test -f $BIN_HOME/$ostoolbin; then rm $BIN_HOME/$ostoolbin; fi
   if test -f $BIN_HOME/$toolbin; then rm $BIN_HOME/$toolbin; fi

   tar xvf $BIN_HOME/$targz -C $BIN_HOME ./$ostoolbin 

   cp $BIN_HOME/$ostoolbin $BIN_HOME/$toolbin
}

#
# yq
#

yq_tar=""

if compare_values $os "Darwin"; then
   if compare_values $machine "x86_64"; then
      yq_tar=yq_darwin_amd64.tar.gz
   else
      yq_tar=yq_darwin_arm64.tar.gz
   fi
else
   if compare_values $machine "x86_64"; then
      yq_tar=yq_linux_amd64.tar.gz
   else
      yq_tar=yq_linux_arm64.tar.gz
   fi
fi

if test -z $yq_tar; then
   echo yq tar name undefined, uname: `uname -a`
   exit 1
fi

if test ! -f $BIN_HOME/$yq_tar; then
   echo yq tar file $BIN_HOME/$yq_tar not found
   exit 1
fi

echo ""
echo installing $yq_tar to $BIN_HOME
echo ""

install_tar $yq_tar yq
