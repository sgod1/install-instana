#!/bin/bash

source ../instana.env
source ./install.env
source ./help-functions.sh

export PATH=".:$PATH"

# return code
rc=0

# debug offline
offline_mode=$1

if test $offline_mode; then
   online=""
   offline="offline"

else
   online="online"
fi

profile=$INSTANA_INSTALL_PROFILE
version=$INSTANA_VERSION

tls_home=$(get_tls_home)

# key, cert prefix
prefix="ingress"
tls-key-cert.sh "$prefix" "$profile" 
check_return_code $?

log_msg0 $0 "deleting tls secret instana-tls"
if test $online; then
   $KUBECTL delete secret instana-tls --namespace instana-core
else
   echo $offline
fi

log_msg0 $0 "creating tls secret instana-tls"
key_file=$(format_file_path $tls_home "${prefix}-key.pem" $profile $version)
cert_file=$(format_file_path $tls_home "${prefix}-cert.pem" $profile $version)
ca_file=$(format_file_path $tls_home "${prefix}-root-ca-cert.pem" $profile $version)

if test $online; then
   $KUBECTL create secret tls instana-tls --namespace instana-core \
       --cert=<(cat $cert_file $ca_file) \
       --key=$key_file
   rc=$?
else
   echo $offline
fi

check_return_code $rc

exit $rc
