#!/bin/bash

source ../instana.env
source ./help-functions.sh
source ./install.env

tls_home=$(get_make_tls_home)
bin_home=$(get_bin_home)

# ingress alt subject names
#__ingress_alt_subj_names=("$INSTANA_BASE_DOMAIN" "agent-acceptor.$INSTANA_BASE_DOMAIN" "otlp-grpc.$INSTANA_BASE_DOMAIN" "otlp-http.$INSTANA_BASE_DOMAIN" "$INSTANA_TENANT_DOMAIN")
__ingress_alt_subj_names=("$INSTANA_BASE_DOMAIN" "$(instana_agent_acceptor $INSTANA_BASE_DOMAIN)" "$(instana_otlp_grpc_acceptor $INSTANA_BASE_DOMAIN)" "$(instana_otlp_http_acceptor $INSTANA_BASE_DOMAIN)" "$(instana_tenant_domain $INSTANA_UNIT_NAME $INSTANA_TENANT_NAME $INSTANA_BASE_DOMAIN)" "$(instana_oem_acceptor $INSTANA_BASE_DOMAIN)" "$(instana_serverless_acceptor $INSTANA_BASE_DOMAIN)" "$(instana_synthetics_acceptor $INSTANA_BASE_DOMAIN)")

# subdomain or single_ingress
ingress=${INSTANA_INGRESS:-"subdomain"}

if [[ $ingress == single_ingress ]]; then
   __ingress_alt_subj_names=("$INSTANA_BASE_DOMAIN")
fi

# csr env
csr_env_yaml=$CSR_ENV_FILE_NAME

function prefix_file_name() {
  local filename=$1
  local prof=$2
  local home=$(get_tls_home)

  format_file_path $home $filename $prof
}

function write_dn_config() {
  local dns="$1"
  local outfile="$2"
  local prof="$3"

  echo "" >> $outfile
  echo "[ dn ]" >> $outfile

  for dn in $dns; do
    val=`$bin_home/yq ".env.[]|select(.path==\".csr.dn\")|.values.$prof | .$dn" $csr_env_yaml | tr -d "-"`
    echo $dn = $val >> $outfile
  done

  # cn is not included in dn env
  echo CN = $INSTANA_BASE_DOMAIN >> $outfile
}

function write_csr_config() {
  local outfile=$1
  local prof=$2

  # use input prof
  default_bits=`$bin_home/yq ".env.[]|select(.path==\".csr.default-bits\")|.values.$prof|." $csr_env_yaml`
  if test "$default_bits" = "null"; then
    # use default profile
    default_bits=`$bin_home/yq ".env.[]|select(.path==\".csr.default-bits\")|.values.default|." $csr_env_yaml`
  fi

  # use input prof
  default_md=`$bin_home/yq ".env.[]|select(.path==\".csr.default-md\")|.values.$prof|." $csr_env_yaml`
  if test "$default_md" = "null"; then
    # use default prof
    default_md=`$bin_home/yq ".env.[]|select(.path==\".csr.default-md\")|.values.default|." $csr_env_yaml`
  fi

  # write req section
  echo "[ req ]" > $outfile

  echo "default_bits = $default_bits" >> $outfile
  echo "default_md = $default_md" >> $outfile

  echo "prompt = no" >> $outfile
  echo "x509_extensions = req_ext" >> $outfile
  echo "req_extensions = req_ext" >> $outfile
  echo "distinguished_name = dn" >> $outfile

  # use input prof
  dns=`$bin_home/yq ".env.[]|select(.path==\".csr.dn\")|.values.$prof | select(.) | keys" $csr_env_yaml | tr -d "-"`
  if test ! -z "$dns"; then
    write_dn_config "$dns" $outfile $prof

  else
    # use default prof
    dns=`$bin_home/yq ".env.[]|select(.path==\".csr.dn\")|.values.default | select(.) | keys" $csr_env_yaml | tr -d "-"`
    write_dn_config "$dns" $outfile "default"
  fi

  echo "" >> $outfile
  echo "[ req_ext ]" >> $outfile
  echo "subjectAltName = @alt_names" >> $outfile

  # write alt_names section
  echo "" >> $outfile
  echo "[ alt_names ]" >> $outfile

  declare -i lnum=1
  for san in ${__ingress_alt_subj_names[@]}; do
    echo DNS.$((lnum++)) = $san >> $outfile
  done
}

#
# main
#

# output name qualifier: ingress, sp
qual="$1"
prof="$2"
passfile="$3"

# ingress-csr, sp-csr
csr_file_name="${qual}-${CSR_FILE_NAME}"
key_file_name="${qual}-${KEY_FILE_NAME}"

csr_file=$(prefix_file_name $csr_file_name $prof)
key_file=$(prefix_file_name $key_file_name $prof)

# check for private key file
if test -f $key_file; then
   echo ... reusing existing private key $key_file
   exit 0
fi

# write csr config file
csr_config_file_name="${qual}-${CSR_CONFIG_FILE_NAME}"
csr_config_file=$(prefix_file_name $csr_config_file_name $prof)

write_csr_config $csr_config_file "$prof"

echo ... csr config $csr_config_file
cat $csr_config_file
echo

if test "$passfile" && test -f "$passfile"; then
   echo "... reading key password file $passfile"
   keypass="-passout file:$passfile"
else
   echo "... no key password file, key is unencrypted"
   keypass="${OPENSSL_KEYPASS_ARG}"
fi

echo ... generating csr, config file $csr_config_file, csr file $csr_file, key file $key_file
echo

openssl req -newkey rsa:2048 \
   -keyout $key_file -out $csr_file \
   $keypass -config $csr_config_file 2> ./gen/tls/${qual}-openssl-newkey.err
check_return_code $?

#
# use internal ca to issue cert - deprecated
#
root_ca_key_file_name="${qual}-${ROOT_CA_KEY_FILE_NAME}"
root_ca_key_file=$(prefix_file_name $root_ca_key_file_name $prof)

root_ca_cert_file_name="${qual}-${ROOT_CA_CERT_FILE_NAME}"
root_ca_cert_file=$(prefix_file_name $root_ca_cert_file_name $prof)

root_ca_subject=$ROOT_CA_SUBJECT

#
# root ca private key - deprecated
#
#echo ... creating root ca private key, file $root_ca_key_file
#echo 
#openssl genrsa -out $root_ca_key_file 2048 2> ./gen/tls/${qual}-openssl-rootca-key.err
#check_return_code $?

#
# self-signed root ca cert (req -new -x509), reuse private -key ca.crt
#
#echo ... creating root ca cert, file $root_ca_cert_file
#echo
#openssl req -new -x509 -days 365 -key $root_ca_key_file -subj "$root_ca_subject" \
#   -out $root_ca_cert_file 2> ./gen/tls/${qual}-openssl-rootca-ss-cert.err
#check_return_code $?

#
# issue cert from csr, use extension file (x509 -req -extfile)
#

cert_file_name="${qual}-cert.pem"
cert_file=$(prefix_file_name $cert_file_name $prof)

sanlist=""
for san in ${__ingress_alt_subj_names[@]}; do
  if test -z $sanlist; then
    sanlist="subjectAltName=DNS:$san"
  else
    sanlist="${sanlist},DNS:$san"
  fi
done

sanlist_file="./gen/tls/${qual}-sanlist.ext"

echo ... writing sanlist to $sanlist_file
echo $sanlist > $sanlist_file

#openssl x509 -req -days 365 -in $csr_file \
#   -extfile <(printf $sanlist) \
#   -CA $root_ca_cert_file -CAkey $root_ca_key_file -CAcreateserial \
#   -out $cert_file
#check_return_code $?

if test "$passfile" && test -f "$passfile"; then
   echo "... reading key password file $passfile"
   keypassin="-passin file:$passfile"
else
   echo "... no key password file, key is unencrypted"
   keypassin=""
fi

echo ... issuing certificate, csr $csr_file, cert $cert_file
echo

openssl x509 -req -days 365 -in $csr_file \
   -signkey $key_file $keypassin \
   -extfile $sanlist_file \
   -out $cert_file 2> ./gen/tls/${qual}-openssl-ss-cert.err
check_return_code $?

#
# create cert chain
#
cert_chain_file_name="${qual}-${CERT_CHAIN_FILE_NAME}"
cert_chain_file=$(prefix_file_name $cert_chain_file_name $prof)

echo ... writing cert chain ... $cert_chain_file

cat $cert_file > $cert_chain_file
