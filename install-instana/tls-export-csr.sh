#!/bin/bash

source ../instana.env
source ./install.env
source ./help-functions.sh

export PATH=".:$PATH"

# export csr to external file

# qualifier: ingress|sp
qual=$1

# exportdir|show
if [[ -z $2 ]]; then
	echo "missing argument, usage: sp|ingress show|exportdir"
	exit 1
fi

# showpath: show
showpath=${2:-"noshow"}

# export directory
exportdir=$2


tls_home=$(get_make_tls_home)

if [[ -z $qual ]]; then
	echo "qualifer agrument required: sp|ingress"
	exit 1

elif [[ $qual == "sp" ]]; then
	echo ""

elif [[ $qual == "ingress" ]]; then
	echo ""

else
	echo "invalid qualifer agrument $qual, expected sp|ingress"
	exit 1
fi

csr_file=$(format_file_path $tls_home "${qual}-${CSR_FILE_NAME}" $INSTANA_INSTALL_PROFILE $INSTANA_VERSION)

if [[ ! -f $csr_file ]]; then
	echo "csr file not found... $csr_file"
	exit 1
fi

# show csr path
if [[ $showpath == "show" ]]; then
	echo "show csr file: $csr_file"
	exit 0
fi

# copy csr to export directory
if [[ ! -d $exportdir ]]; then
	echo export directory not found: $exportdir
	exit 1
fi

echo writing csr $csr_file to export directory $exportdir
echo ""

cp $csr_file $exportdir
