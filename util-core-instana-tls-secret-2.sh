#!/bin/bash

source ../instana.env
source ./help-functions.sh

replace_manifest=${1:-"no_replace"}

echo "generating SSL certificates tls.csr/tls.key ..."
echo 

# todo: use configuration parameters for subject values
openssl genrsa -out ca.key 2048 2> /dev/null
check_return_code $?

openssl req -new -x509 -days 365 -key ca.key \
     -subj "/C=CN/ST=GD/L=SZ/O=IBM/CN=IBM Root CA" -out ca.crt 2> /dev/null
check_return_code $?

openssl req -newkey rsa:2048 -nodes -keyout tls.key \
     -subj "/C=CN/ST=GD/L=SZ/O=IBM./CN=*.${INSTANA_BASE_DOMAIN}" -out tls.csr 2> /dev/null
check_return_code $?

openssl x509 -req -extfile <(printf "subjectAltName=DNS:${INSTANA_BASE_DOMAIN},DNS:${INSTANA_TENANT_DOMAIN},DNS:${INSTANA_AGENT_ACCEPTOR},DNS:${INSTANA_OTLP_GRPC_ACCEPTOR},DNS:${INSTANA_OTLP_HTTP_ACCEPTOR}") \
        -days 365 -in tls.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out tls.crt 2> /dev/null
check_return_code $?

echo "creating tls secret instana-tls"
echo

if compare_values "$replace_manifest" "replace"; then
   echo replacing instana-tls secret, namespace instana-core
   $KUBECTL delete secret instana-tls --namespace instana-core
fi

$KUBECTL create secret tls instana-tls --namespace instana-core \
    --cert=tls.crt \
    --key=tls.key 
rc=$?

# delete generated keys
rm ./tls.key ./tls.crt ./tls.csr ./ca.key ./ca.crt ./ca.srl

check_return_code $rc
