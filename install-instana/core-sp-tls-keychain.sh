#!/bin/bash

source ../instana.env
source ./help-functions.sh
source ./install.env

profile=${1:-$INSTANA_INSTALL_PROFILE}
tls_home=$(get_make_tls_home)

function concat_keychain() {
   local prefix=$1

   local version=$INSTANA_VERSION
   local profile=$INSTANA_INSTALL_PROFILE

   #
   # create keychain: encr(key)/cert/ca-cert
   #
   key_file=$(format_file_path $tls_home "${prefix}-key.pem" $profile $version)
   cert_file=$(format_file_path $tls_home "${prefix}-cert.pem" $profile $version)
   ca_file=$(format_file_path $tls_home "${prefix}-root-ca-cert.pem" $profile $version)

   #key_file="$tls_home/$qual-key-$profile-$version.pem"
   #cert_file="$tls_home/$qual-cert-$profile-$version.pem"
   #ca_file="$tls_home/$qual-root-ca-cert-$profile-$version.pem"

   keychain=$(format_file_path $tls_home $CORE_CONFIG_SP_KEYCHAIN_FILE $profile $version)

   echo
   echo ... concat $key_file $cert_file $ca_file into $keychain
   echo

   cat $key_file $cert_file $ca_file > $keychain
}

#
# main
#

keypass_file="gen/tls/core-sp-keypass.pass"

# write out sp key passfile
echo "$CORE_CONFIG_SP_KEY_PASSWORD" > "$keypass_file"

qual="sp"
./tls-key-cert.sh "$qual" "$profile" "$keypass_file"

check_return_code $?

# concat keychain
concat_keychain $qual

