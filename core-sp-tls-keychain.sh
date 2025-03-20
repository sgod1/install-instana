#!/bin/bash

source ../instana.env
source ./help-functions.sh
source ./install.env

profile=${1:-$INSTANA_INSTALL_PROFILE}
tls_home=$(get_make_tls_home)

function concat_keychain() {
   local qual=$1

   local version=$INSTANA_VERSION

#... generating csr, config file gen/tls/sp-conf-uat-289.conf, csr file gen/tls/sp-csr-uat-289.pem, key file gen/tls/sp-key-uat-289.pem
#... reading password file gen/tls/keypass.pass
#... creating root ca private key, file gen/tls/sp-root-ca-key-uat-289.pem
#... creating root ca cert, file gen/tls/sp-root-ca-cert-uat-289.pem
#... issuing certificate, csr gen/tls/sp-csr-uat-289.pem, cert gen/tls/sp-cert-uat-289.pem

   #
   # create keychain: encr(key)/cert/ca-cert
   #
   key_file="$tls_home/$qual-key-$profile-$version.pem"
   cert_file="$tls_home/$qual-cert-$profile-$version.pem"
   ca_file="$tls_home/$qual-root-ca-cert-$profile-$version.pem"

   keychain=$(format_file_path $tls_home $CORE_CONFIG_SP_KEYCHAIN_FILE $profile $version)

   echo
   echo ... concat $key_file $cert_file $ca_file into $keychain
   echo

   cat $key_file $cert_file $ca_file > $keychain
}

#
# main
#

keypass_file="gen/tls/keypass.pass"

# write out sp key passfile
echo "$CORE_CONFIG_SP_KEY_PASSWORD" > "$keypass_file"

qual="sp"
./tls-key-cert.sh "$qual" "$profile" "$keypass_file"

check_return_code $?

# concat keychain
concat_keychain $qual

