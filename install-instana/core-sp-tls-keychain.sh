#!/bin/bash

source ../instana.env
source ./help-functions.sh
source ./install.env

# qualifier: sp or custom
qual=${1:-"sp"}

profile=${INSTANA_INSTALL_PROFILE}

tls_home=$(get_make_tls_home)

function concat_keychain() {
   local prefix=$1

   local version=$INSTANA_VERSION
   local profile=$INSTANA_INSTALL_PROFILE

   #
   # create keychain: encr(key)/cert/ca-cert
   #
   key_file=$(format_file_path $tls_home "${prefix}-${KEY_FILE_NAME}" $profile)
   cert_chain_file=$(format_file_path $tls_home "${prefix}-${CERT_CHAIN_FILE_NAME}" $profile)

   keychain=$(format_file_path $tls_home "${prefix}-${CORE_CONFIG_SP_KEYCHAIN_FILE}" $profile)

   echo
   echo ... writing $key_file $cert_chain_file into $keychain
   echo

   cat $key_file $cert_chain_file > $keychain
}

#
# main
#

keypass_file="${tls_home}/${CORE_CONFIG_SP_KEY_PASSWORD_FILE}"

# write out sp key passfile
echo "$CORE_CONFIG_SP_KEY_PASSWORD" > "$keypass_file"

./tls-key-cert.sh "$qual" "$profile" "$keypass_file"

check_return_code $?

# concat keychain
concat_keychain $qual