#!/bin/bash

source ../instana.env
source ./install.env
source ./help-functions.sh

tls_home=$(get_make_tls_home)

input_ca_bundle=$1

if [[ -z $input_ca_bundle ]]; then
	echo "input bundle file argument required"
	echo ""
	exit 1

elif [ ! -f $input_ca_bundle ]; then
	echo "input ca bundle not found... $input_ca_bundle"
	echo ""
	exit 1
fi

# import ca bundle
ca_bundle=$(format_file_path $tls_home $CORE_CONFIG_CUSTOM_CA_BUNDLE_FILE $INSTANA_INSTALL_PROFILE)

echo copying $input_ca_bundle to $ca_bundle
echo ""

cp $input_ca_bundle $ca_bundle
rc=$?

check_return_code $rc

exit $rc
