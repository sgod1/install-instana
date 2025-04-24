#!/bin/bash

export PATH=".:$PATH"

source ../instana.env
source ./install.env
source ./help-functions.sh

# qualifier: ingress|sp
qual=$1

profile=${INSTANA_INSTALL_PROFILE}

tls_home=$(get_make_tls_home)

if [[ -z $qual ]]; then

	echo "qualifer agrument required... ingress|sp"
	exit 1

elif [[ $qual == "sp" ]]; then

	# write out sp key passfile
	keypass_file="${tls_home}/${CORE_CONFIG_SP_KEY_PASSWORD_FILE}"

	echo "$CORE_CONFIG_SP_KEY_PASSWORD" > "$keypass_file"

elif [[ $qual == "ingress" ]]; then

	keypass_file = ""

else

	echo "Invalid qalifier agrument $qual, expected... ingress|sp"
	exit 1

fi

tls-key-cert.sh $qual $profile $keypass_file
rc=$?

check_return_code $rc