#!/bin/bash

source ../instana.env
source ./install.env
source ./help-functions.sh

export PATH=".:$PATH"

# return code
rc=0

# qualifier: ingress or custom
qualifier=${1:-"ingress"}

profile=$INSTANA_INSTALL_PROFILE
version=$INSTANA_VERSION

tls_home=$(get_tls_home)

# key, cert
tls-key-cert.sh "$qualifier" "$profile" 
check_return_code $?

log_msg0 $0 "deleting tls secret instana-tls"
$KUBECTL delete secret instana-tls --namespace instana-core

log_msg0 $0 "creating tls secret instana-tls"
key_file=$(format_file_path $tls_home "${qualifier}-key.pem" $profile $version)
cert_file=$(format_file_path $tls_home "${qualifier}-cert.pem" $profile $version)
ca_file=$(format_file_path $tls_home "${qualifier}-root-ca-cert.pem" $profile $version)

if [[ -f $ca_file ]]; then
   # root cert file

   $KUBECTL create secret tls instana-tls --namespace instana-core \
      --cert=<(cat $cert_file $ca_file) \
      --key=$key_file
   rc=$?

else
   # root cert within cert chain

   $KUBECTL create secret tls instana-tls --namespace instana-core \
      --cert=<(cat $cert_file) \
      --key=$key_file
   rc=$?

fi

check_return_code $rc

exit $rc
