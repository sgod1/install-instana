#!/bin/bash

source ../instana.env
source ./help-functions.sh

BIN_HOME=$(get_bin_home)
KTLPLUGIN=$BIN_HOME/kubectl-instana

echo checkfing for instana kubectl plugin $KTLPLUGIN

if test ! -f $KTLPLUGIN; then
   echo instana  kubectl plugin $KTLPLUGIN not found
   exit 1
fi

LICENSE_FILE=$BIN_HOME/license.json

echo downloading instana license file to $LICENSE_FILE
$KTLPLUGIN license download --sales-key $SALES_KEY  --filename $LICENSE_FILE
