#!/bin/bash

source ../../instana.env
source ../help-functions.sh

BIN_DIR=$(get_make_bin_home)

if test -f $BIN_DIR/kubectl; then rm $BIN_DIR/kubectl; fi

echo installing kubectl to $BIN_DIR
echo ""

# kubernetes 1.30
wget "https://s3.us-west-2.amazonaws.com/amazon-eks/1.30.2/2024-07-12/bin/linux/amd64/kubectl" -P $BIN_DIR

chmod +x $BIN_DIR/kubectl
