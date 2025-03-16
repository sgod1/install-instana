#!/bin/bash

source ../instana.env
source ./help-functions.sh
source ./install.env

ingress_home=$(get_make_ingress_home)

# ingress alt subject names
__ingress_alt_subj_names=("$INSTANA_BASE_DOMAIN" "agent-acceptor.$INSTANA_BASE_DOMAIN" "otlp-grpc.$INSTANA_BASE_DOMAIN" "otlp-http.$INSTANA_BASE_DOMAIN" "$INSTANA_TENANT_DOMAIN")

# ingress csr env
ingress_csr_env_yaml=$INGRESS_CSR_ENV_FILE

function prefix_file_name() {
  local filename=$1
  local prof=$2
  echo "$(get_ingress_home)/${prof}-$filename"
}

function write_dn_config() {
  local dns="$1"
  local outfile="$2"
  local prof="$3"

  echo "" >> $outfile
  echo "[ dn ]" >> $outfile

  for dn in $dns; do
    val=`gen/bin/yq ".env.[]|select(.path==\".csr.dn\")|.values.$prof | .$dn" $ingress_csr_env_yaml | tr -d "-"`
    echo $dn = $val >> $outfile
  done

  # cn is not included in dn env
  echo CN = $INSTANA_BASE_DOMAIN >> $outfile
}

function write_csr_config() {
  local outfile=$1
  local prof=$2

  # use input prof
  default_bits=`gen/bin/yq ".env.[]|select(.path==\".csr.default-bits\")|.values.$prof|." $ingress_csr_env_yaml`
  if test "$default_bits" = "null"; then
    # use default profile
    default_bits=`gen/bin/yq ".env.[]|select(.path==\".csr.default-bits\")|.values.default|." $ingress_csr_env_yaml`
  fi

  # use input prof
  default_md=`gen/bin/yq ".env.[]|select(.path==\".csr.default-md\")|.values.$prof|." $ingress_csr_env_yaml`
  if test "$default_md" = "null"; then
    # use default prof
    default_md=`gen/bin/yq ".env.[]|select(.path==\".csr.default-md\")|.values.default|." $ingress_csr_env_yaml`
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
  dns=`gen/bin/yq ".env.[]|select(.path==\".csr.dn\")|.values.$prof | select(.) | keys" $ingress_csr_env_yaml | tr -d "-"`
  if test ! -z "$dns"; then
    write_dn_config "$dns" $outfile $prof

  else
    # use default prof
    dns=`gen/bin/yq ".env.[]|select(.path==\".csr.dn\")|.values.default | select(.) | keys" $ingress_csr_env_yaml | tr -d "-"`
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

prof=${1:-$INSTANA_INSTALL_PROFILE}

ingress_csr_file=$(prefix_file_name $INGRESS_CSR_FILE $prof)
ingress_key_file=$(prefix_file_name $INGRESS_KEY_FILE $prof)

# check for private key file
if test -f $ingress_key_file; then
   echo ingress private key $ingress_key_file already exits, exiting
   exit 1
fi

# write csr config file
csr_config_file=$(prefix_file_name $INGRESS_CSR_CONFIG_FILE $prof)

write_csr_config $csr_config_file "$prof"

echo ... csr config $csr_config_file
cat $csr_config_file
echo

echo ... generating csr, config file $csr_config_file, csr file $ingress_csr_file, key file $ingress_key_file
echo
openssl req -newkey rsa:2048 \
   -keyout $ingress_key_file -out $ingress_csr_file \
   -days 365 -nodes -config $csr_config_file 2> /dev/null
check_return_code $?

#
# use internal ca to issue ingress cert
#
ingress_root_ca_key_file=$(prefix_file_name $INGRESS_ROOT_CA_KEY_FILE $prof)
ingress_root_ca_cert_file=$(prefix_file_name $INGRESS_ROOT_CA_CERT_FILE $prof)

ingress_root_ca_subject="/OU=${prof}${INGRESS_ROOT_CA_SUBJECT}"

#
# root ca private key
#
echo ... creating root ca private key, file $ingress_root_ca_key_file
echo 
openssl genrsa -out $ingress_root_ca_key_file 2048 2> /dev/null
check_return_code $?

#
# self-signed root ca cert (req -new -x509), reuse private -key ca.crt
#
echo ... creating root ca cert, file $ingress_root_ca_cert_file
echo
openssl req -new -x509 -days 365 -key $ingress_root_ca_key_file -subj "$ingress_root_ca_subject" \
   -out $ingress_root_ca_cert_file 2> /dev/null
check_return_code $?

#
# issue cert from csr, use extension file (x509 -req -extfile)
#
ingress_cert_file=$(prefix_file_name $INGRESS_CERT_FILE $prof)

sanlist=""
for san in ${__ingress_alt_subj_names[@]}; do
  if test -z $sanlist; then
    sanlist="subjectAltName=DNS:$san"
  else
    sanlist="${sanlist},DNS:$san"
  fi
done

echo ... issuing ingress certificate, csr $ingress_csr_file, cert $ingress_cert_file
echo

openssl x509 -req -days 365 -in $ingress_csr_file \
   -extfile <(printf $sanlist) \
   -CA $ingress_root_ca_cert_file -CAkey $ingress_root_ca_key_file -CAcreateserial \
   -out $ingress_cert_file
check_return_code $?

