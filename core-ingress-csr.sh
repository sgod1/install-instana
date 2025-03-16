#!/bin/bash

source ../instana.env
source ./help-functions.sh
source ./install.env

function write_alt_subj_names() {
  local outfile=$1

  echo $INSTANA_BASE_DOMAIN > $outfile
  echo agent-acceptor.$INSTANA_BASE_DOMAIN >> $outfile
  echo otlp-grpc.$INSTANA_BASE_DOMAIN >> $outfile
  echo otlp-http.$INSTANA_BASE_DOMAIN >> $outfile
  echo $INSTANA_TENANT_DOMAIN >> $outfile
}

function write_dn_config() {
  local dns="$1"
  local outfile="$2"
  local prof="$3"

  echo "" >> $outfile
  echo "[ dn ]" >> $outfile

  for dn in $dns; do
    val=`gen/bin/yq ".env.[]|select(.path==\".csr.dn\")|.values.$prof | .$dn" core-ingress-csr-env.yaml | tr -d "-"`
    echo $dn = $val >> $outfile
  done

  echo CN = $INSTANA_BASE_DOMAIN >> $outfile
}

function write_csr_config() {
  local outfile=$1
  local prof=$2

  # use input profile
  default_bits=`gen/bin/yq ".env.[]|select(.path==\".csr.default-bits\")|.values.$prof|." core-ingress-csr-env.yaml`
  if test "$default_bits" = "null"; then
    # use default profile
    default_bits=`gen/bin/yq ".env.[]|select(.path==\".csr.default-bits\")|.values.default|." core-ingress-csr-env.yaml`
  fi

  # use input profile
  default_md=`gen/bin/yq ".env.[]|select(.path==\".csr.default-md\")|.values.$prof|." core-ingress-csr-env.yaml`
  if test "$default_md" = "null"; then
    # use default profile
    default_md=`gen/bin/yq ".env.[]|select(.path==\".csr.default-md\")|.values.default|." core-ingress-csr-env.yaml`
  fi

  echo "[ req ]" > $outfile

  echo "default_bits = $default_bits" >> $outfile
  echo "default_md = $default_md" >> $outfile

  echo "prompt = no" >> $outfile
  echo "x509_extensions = req_ext" >> $outfile
  echo "req_extensions = req_ext" >> $outfile
  echo "distinguished_name = dn" >> $outfile

  # use input prof
  dns=`gen/bin/yq ".env.[]|select(.path==\".csr.dn\")|.values.$prof | select(.) | keys" core-ingress-csr-env.yaml | tr -d "-"`
  if test ! -z "$dns"; then
    write_dn_config "$dns" $outfile $prof

  else
    # use default prof
    dns=`gen/bin/yq ".env.[]|select(.path==\".csr.dn\")|.values.default | select(.) | keys" core-ingress-csr-env.yaml | tr -d "-"`
    write_dn_config "$dns" $outfile "default"
  fi

  echo "" >> $outfile
  echo "[ req_ext ]" >> $outfile
  echo "subjectAltName = @alt_names" >> $outfile

  alt_subj_names_file="gen/${prof}-core-ingress-alt-subj-names.list"
  write_alt_subj_names $alt_sub_names_file

  echo "" >> $outfile
  echo "[ alt_names ]" >> $outfile

  declare -i lnum=1
  for line in `cat $alt_subj_names_file`; do
    #echo DNS.$((lnum++)) = $line >> $outfile
    echo DNS = $line >> $outfile
  done
}

function out_file_name() {
  local symname=$1
  local prof=$2
  
  echo "gen/${prof}-${symname}"
}

prof="zorro"

csr_config_file=$(out_file_name $CORE_INGRESS_TLS_CONFIG_FILE "$prof")

# write csr config file
write_csr_config $csr_config_file "$prof"

echo ... generated csr config $csr_config_file
cat $csr_config_file
echo

#
# use configuration file with csr options to generate private key and csr
#
csr_file=$(out_file_name $CORE_INGRESS_CSR_FILE "$prof")
key_file=$(out_file_name $CORE_INGRESS_TLS_KEY_FILE "$prof")

echo ... generating csr, config file $csr_config_file, csr file $csr_file, key file $key_file
echo
openssl req -newkey rsa:2048 \
   -keyout $key_file -out $csr_file \
   -days 365 -nodes -config $csr_config_file 2> /dev/null
check_return_code $?

#
# use internal ca to sign csr
#
CORE_INGRESS_CA_KEY_FILE="gen/${prof}-core-ingress-ca-key.pem"
CORE_INGRESS_CA_CERT_FILE="gen/${prof}-core-ingress-ca-cert.pem"

ROOT_CA_SUBJECT="/OU=${prof}/O=Core/CN=Ingress Root CA"

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
openssl x509 -req -days 365 -in $csr_file \
   -extfile <(printf "subjectAltName=DNS:${INSTANA_BASE_DOMAIN},DNS:${INSTANA_TENANT_DOMAIN},DNS:${INSTANA_AGENT_ACCEPTOR},DNS:${INSTANA_OTLP_GRPC_ACCEPTOR},DNS:${INSTANA_OTLP_HTTP_ACCEPTOR}") \
   -CA $CORE_INGRESS_CA_CERT_FILE -CAkey $CORE_INGRESS_CA_KEY_FILE -CAcreateserial \
   -out $CORE_INGRESS_CERT_FILE
check_return_code $?
