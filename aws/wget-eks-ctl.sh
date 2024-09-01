#!/bin/bash

source ../../instana.env
source ../help-functions.sh

BIN_DIR=$(get_make_bin_home)

# for ARM set ARCH to: `arm64`, `armv6` or `armv7`

ARCH=amd64
PLATFORM=$(uname -s)_$ARCH

EKSCTL_TAR="eksctl_$PLATFORM.tar.gz"

# https://eksctl.io/installation
#curl -sLO "https://github.com/eksctl-io/eksctl/releases/latest/download/eksctl_$PLATFORM.tar.gz"
#curl -sL "https://github.com/eksctl-io/eksctl/releases/latest/download/eksctl_checksums.txt" | grep $PLATFORM | sha256sum --check

if -f $BIN_DIR/$EKSCTL_TAR; then
   rm $BIN_DIR/$EKSCTL_TAR
fi

wget "https://github.com/eksctl-io/eksctl/releases/latest/download/$EKSCTL_TAR" -P $BIN_DIR

echo installing eksctl to $BIN_DIR
echo ""

tar -xzf $BIN_DIR/$EKSCTL_TAR -C $BIN_DIR
