#!/bin/bash

source ../instana.env
source ./help-functions.sh

CORE_INGRESS_TLS_KEY_FILE="gen/core-ingress-tls-key.pem"
CORE_INGRESS_TLS_CONFIG_FILE="gen/core-ingress-tls.conf"
CORE_INGRESS_CSR_FILE="gen/core-ingress-csr.pem"
CORE_INGRESS_CERT_FILE="gen/core-ingress-ss-cert.pem"

CORE_INGRESS_CA_KEY_FILE="gen/core-ingress-ca-key.pem"
CORE_INGRESS_CA_CERT_FILE="gen/core-ingress-ca-cert.pem"

ROOT_CA_SUBJECT="/C=US/ST=GA/L=Alpharetta/O=TSYS/CN=TSYS Root CA"

CSR_DN_C="US"
CSR_DN_ST="GA"
CSR_DN_L="Alpharetta"
CSR_DN_O="TSYS"
CSR_DN_OU="SRE"
CSR_DN_EMAIL="sre@tsys.com"

# todo: check replace flag

#
# write out configuration file
#
echo ... writing tls config file $CORE_INGRESS_TLS_CONFIG_FILE
echo

cat << EOF > $CORE_INGRESS_TLS_CONFIG_FILE
[req]
default_bits = 4096
prompt = no
default_md = sha256
x509_extensions = req_ext
req_extensions = req_ext
distinguished_name = dn
[ dn ]
C=$CSR_DN_C
ST=$CSR_DN_ST
L=$CSR_DN_L
O=$CSR_DN_O
OU=$CSR_DN_OU
emailAddress=$CSR_DN_EMAIL
CN = $INSTANA_BASE_DOMAIN
[ req_ext ]
subjectAltName = @alt_names
[ alt_names ]
DNS.1 = $INSTANA_BASE_DOMAIN
DNS.2 = agent-acceptor.$INSTANA_BASE_DOMAIN
DNS.3 = otlp-grpc.$INSTANA_BASE_DOMAIN
DNS.4 = otlp-http.$INSTANA_BASE_DOMAIN
DNS.5 = $INSTANA_TENANT_DOMAIN
EOF

#
# use configuration file with csr options to generate private key and csr
#
echo ... generating csr, config file $CORE_INGRESS_TLS_CONFIG_FILE, csr file $CORE_INGRESS_CSR_FILE
echo
openssl req -newkey rsa:2048 \
   -keyout $CORE_INGRESS_TLS_KEY_FILE -out $CORE_INGRESS_CSR_FILE \
   -days 365 -nodes -config $CORE_INGRESS_TLS_CONFIG_FILE 2> /dev/null
check_return_code $?


#
# new ca private key
#
echo ... creating ca private key, file $CORE_INGRESS_CA_KEY_FILE
echo 
openssl genrsa -out $CORE_INGRESS_CA_KEY_FILE 2048 2> /dev/null
check_return_code $?

#
# new self-signed root ca cert (req -new -x509), reuse private -key ca.crt
#
echo ... creating root ca cert, file $CORE_INGRESS_CA_CERT_FILE
echo
openssl req -new -x509 -days 365 -key $CORE_INGRESS_CA_KEY_FILE -subj "$ROOT_CA_SUBJECT" \
   -out $CORE_INGRESS_CA_CERT_FILE 2> /dev/null
check_return_code $?

#
# issue cert from csr, use extension file (x509 -req -extfile)
#
echo ... issuing certificate, csr $CORE_INGRESS_CSR_FILE, cert $CORE_INGRESS_CERT_FILE
echo
openssl x509 -req -days 365 -in $CORE_INGRESS_CSR_FILE \
   -extfile <(printf "subjectAltName=DNS:${INSTANA_BASE_DOMAIN},DNS:${INSTANA_TENANT_DOMAIN},DNS:${INSTANA_AGENT_ACCEPTOR},DNS:${INSTANA_OTLP_GRPC_ACCEPTOR},DNS:${INSTANA_OTLP_HTTP_ACCEPTOR}") \
   -CA $CORE_INGRESS_CA_CERT_FILE -CAkey $CORE_INGRESS_CA_KEY_FILE -CAcreateserial \
   -out $CORE_INGRESS_CERT_FILE
check_return_code $?
