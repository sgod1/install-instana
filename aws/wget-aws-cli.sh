#!/bin/bash

source ../help-functions.sh

BIN_DIR=$(get_make_bin_home)

UNZIP_DIR=$BIN_DIR/unzip
INSTALL_DIR=$BIN_DIR/aws-cli

AWSCLI_ZIP="awscli-exe-linux-x86_64.zip"

if test -d $UNZIP_DIR; then rm -r $UNZIP_DIR; fi
if test -d $INSTALL_DIR; then rm -r $INSTALL_DIR; fi
if test -f $BIN_DIR/$AWSCLI_ZIP; then rm $BIN_DIR/$AWSCLI_ZIP; fi

# https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html
wget "https://awscli.amazonaws.com/$AWSCLI_ZIP" -P $BIN_DIR

unzip $BIN_DIR/$AWSCLI_ZIP -d $UNZIP_DIR

mkdir $INSTALL_DIR

install_path="$(pwd)/$INSTALL_DIR"
bin_path="$(pwd)/$BIN_DIR"

echo installing aws to $BIN_DIR
echo ""

$UNZIP_DIR/aws/install --install-dir $install_path --bin-dir $bin_path

rm -r $UNZIP_DIR
