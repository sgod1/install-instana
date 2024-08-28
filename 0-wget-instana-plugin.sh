#!/bin/bash

source ./release.env
source ../instana.env

source ./help-functions.sh

INSTALL_HOME=$(get_make_install_home)
BIN_DIR=$(get_make_bin_home)

if test -f $BIN_DIR/${INSTANA_PLUGIN_TAR}; then
   rm $BIN_DIR/${INSTANA_PLUGIN_TAR}
fi

cp ./release.env $INSTALL_HOME

wget --user=_ --password=${DOWNLOAD_KEY} -P ${BIN_DIR}  ${INSTANA_PLUGIN_URL}

echo ""
echo installing kubectl-instana to $BIN_DIR
echo ""

tar xvf $BIN_DIR/${INSTANA_PLUGIN_TAR} -C $BIN_DIR
