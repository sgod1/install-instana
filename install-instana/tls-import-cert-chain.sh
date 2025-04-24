#!/bin/bash

source ../instana.env
source ./install.env
source ./help-functions.sh

export PATH=".:$PATH"

tls_home=$(get_make_tls_home)

# import cert chain

# input cert chain
input_cert_chain=$1

# qualifier: ingress|sp
qual=$2

# check input cert chain
# more checks please...

if [[ -z $input_cert_chain ]]; then
	echo "input cert chain argument required"
	echo ""
	exit 1

elif [[ ! -f $input_cert_chain ]]; then
	echo "input cert chain $input_cert_chain not found"
	echo ""
	exit 1
fi

# check qualifier
if [[ -z $qual ]]; then
	echo "qualifer agrument required: sp|ingress"
	echo ""
	exit 1

elif [[ $qual == "sp" ]]; then
	echo ""

elif [[ $qual == "ingress" ]]; then
	echo ""

else
	echo "invalid qualifer agrument $qual, expected sp|ingress"
	echo ""
	exit 1
fi

cert_chain_file=$(format_file_path $tls_home "${qual}-${CERT_CHAIN_FILE_NAME}" $INSTANA_INSTALL_PROFILE $INSTANA_VERSION)

if [[ -f $cert_chain_file ]]; then
	echo "backing up existing cert chain file to ... ${cert_chain_file}.bak"
	cp $cert_chain_file ${cert_chain_file}.bak
fi

# copy input cert chain
echo writing input cert chain $input_cert_chain to $cert_chain_file
echo ""

cp $input_cert_chain $cert_chain_file
check_return_code $?

exit 0
