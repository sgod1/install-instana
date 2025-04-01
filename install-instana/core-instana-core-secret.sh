#!/bin/bash

source ../instana.env
source ./install.env
source ./help-functions.sh

# extend path with current dir
PATH=".:$PATH"

rc_config=0

function check_config_opt_param() {
   local config_param="$1"
   local config_value="$2"

   local val=${config_value:-"optional"}
   check_config_param $config_param $val
}

function check_config_param() {
   local config_param="$1"
   local config_value="$2"

   if test "$config_value" = "optional"; then
      log_msg ... $config_param ... $config_value

   elif test -z $config_value; then
      log_msg "   ... $config_param ... missing ..."
      rc_config=1

   else
     log_msg ... $config_param ... ok
   fi
}

function tls_file_path() {
   local filename=$1
   local profile=$2

   local tls_home=$(get_tls_home)
   local ver=$INSTANA_VERSION

   format_file_path $tls_home $filename $profile $ver
   #echo "$tls_home/${profile}-$filename"
}

function check_opt_file() {
  local filename=$1
  local filepath=$2
  check_file $filename $filepath "optional"
}

function check_file() {
  local filename=$1
  local filepath=$2
  local qualifier=$3

  if test -f $filepath; then
    echo "check file ... $filename: $filepath ... ok ..."

  elif test "$qualifier" = "optional"; then
    echo "check file ... $filename: $filepath ... optional ..."

  else
    echo "   check file ... $filename: $filepath ... missing ..."
    rc_config=1
  fi
}

function check_config() {
   echo
   log_msg $0 validating config
   echo

  check_config_param "INSTANA_VERSION" "$DOWNLOAD_KEY"
  check_config_param "INSTANA_INSTALL_PROFILE" "$INSTANA_INSTALL_PROFILE"

  check_config_param "DOWNLOAD_KEY" "$DOWNLOAD_KEY"
  check_config_param "SALES_KEY" "$SALES_KEY"

  check_config_param "CORE_CONFIG_TOKEN_SECRET" "$CORE_CONFIG_TOKEN_SECRET"
  check_config_param "CORE_CONFIG_RAW_SPANS_TYPE" "$CORE_CONFIG_RAW_SPANS_TYPE"
  check_config_param "CORE_CONFIG_SP_KEY_PASSWORD" "$CORE_CONFIG_SP_KEY_PASSWORD"

  check_config_opt_param "CORE_CONFIG_PROXY_ENABLE" "$CORE_CONFIG_PROXY_ENABLE"
  if test "$CORE_CONFIG_PROXY_ENABLE"; then
    check_config_param "CORE_CONFIG_PROXY_USER" "$CORE_CONFIG_PROXY_USER"
    check_config_param "CORE_CONFIG_PROXY_PASSWORD" "$CORE_CONFIG_PROXY_PASSWORD"
  fi

  check_config_opt_param "CORE_CONFIG_EMAIL_ENABLE_SMTP" "$CORE_CONFIG_EMAIL_ENABLE_SMTP"
  if test "$CORE_CONFIG_EMAIL_ENABLE_SMTP"; then
    check_config_param "CORE_CONFIG_EMAIL_SMTP_USER" "$CORE_CONFIG_EMAIL_SMTP_USER"
    check_config_param "CORE_CONFIG_EMAIL_SMTP_PASSWORD" "$CORE_CONFIG_EMAIL_SMTP_PASSWORD"
  fi

  check_config_opt_param "CORE_CONFIG_EMAIL_ENABLE_AWS_SES" "$CORE_CONFIG_EMAIL_ENABLE_AWS_SES"
  if test "$CORE_CONFIG_EMAIL_ENABLE_AWS_SES"; then
    check_config_param "CORE_CONFIG_AWS_IAM_ACCESS_KEY_ID" "$CORE_CONFIG_AWS_IAM_ACCESS_KEY_ID"
    check_config_param "CORE_CONFIG_AWS_IAM_SECRET_KEY" "$CORE_CONFIG_AWS_IAM_SECRET_KEY"
  fi

  check_config_param "CLICKHOUSE_ADMIN_PASS" "$CLICKHOUSE_ADMIN_PASS"
  check_config_param "CLICKHOUSE_USER_PASS" "$CLICKHOUSE_USER_PASS"

  # todo: check mutual exclusion

  echo
  check_opt_file "CORE_CONFIG_CUSTOM_SP_KEYCHAIN_FILE" $(tls_file_path $CORE_CONFIG_CUSTOM_SP_KEYCHAIN_FILE $INSTANA_INSTALL_PROFILE) 
  check_opt_file "CORE_CONFIG_CUSTOM_CA_BUNDLE_FILE" $(tls_file_path $CORE_CONFIG_CUSTOM_CA_BUNDLE_FILE $INSTANA_INSTALL_PROFILE) 

  if [ $rc_config -gt 0 ]; then
     echo
     log_msg $0 config validation falied, exiting...
     echo

     exit $rc_config
  else
     echo
     log_msg $0 config validation passed...
     echo
  fi
}

#
# main
#

install_home=$(get_install_home)
manifest_home=$(get_manifest_home)

# debug: turn off cluster calls
offline_mode=$1

check_config

check_replace_manifest $config_file $replace_manifest

#
# service provider keychain
# to copy custom keychain:
# core-config-copy-custom-sp-keychain.sh keychain.pem
#
if test -f "$CORE_CONFIG_CUSTOM_SP_KEYCHAIN_FILE"; then
   echo .... unsupported: core-config-custom-sp-keychain-file
   exit 1

else
   core-sp-tls-keychain.sh
   check_return_code $?
fi

#
# to copy custom ca bundle:
# core-config-copy-custom-ca-bundle.sh ca-bundle.pem
#

CORE_CONFIG_FILE="core-config.yaml"
outpath=$(format_file_path $manifest_home $CORE_CONFIG_FILE $INSTANA_INSTALL_PROFILE $INSTANA_VERSION)

# create core-config.yaml
echo
echo ... writing core config to $outpath
echo

cat << EOF > $outpath
# core config.yaml, instana version $INSTANA_VERSION

# The repository password for accessing the Instana agent repository.
# Use the download key that you received from us
repositoryPassword: $DOWNLOAD_KEY

# The sales key you received from IBM
salesKey: $SALES_KEY

# Seed for creating crypto tokens. Pick a random 12 char string
tokenSecret: $CORE_CONFIG_TOKEN_SECRET

# raw spans storage
storageConfigs:
  rawSpans:
EOF

#
# todo: s3 raw spans unsuppored
#
#if compare_values "$CORE_CONFIG_RAW_SPANS_TYPE" "s3"; then
#cat << EOF >> $config_file
#    # Required if using S3 or compatible storage bucket.
#    # Credentials should be configured.
#    # Not required if IRSA on EKS is used.
#    s3Config:
#      accessKeyId: $CORE_CONFIG_AWS_IAM_ACCESS_KEY_ID
#      secretAccessKey: $CORE_CONFIG_AWS_IAM_SECRET_KEY
#
#EOF
#fi

#
# todo: gcp raw spans unsupported
#
#if compare_values "$CORE_CONFIG_RAW_SPANS_TYPE" "gcp"; then
#cat << EOF >> $CORE_CONFIG_FILE
#    # Required if using Google Cloud Storage.
#    # Credentials should be configured.
#    # Not required if GKE with workload identity is used.
#    gcloudConfig:
#      serviceAccountKey: $CORE_CONFIG_GCP_SERVICE_ACCOUNT_KEY
#
#EOF
#fi

#
# service provider keychain
#
sp_keychain_path=$(tls_file_path $CORE_CONFIG_SP_KEYCHAIN_FILE $INSTANA_INSTALL_PROFILE)
custom_sp_keychain_path=$(tls_file_path $CORE_CONFIG_CUSTOM_SP_KEYCHAIN_FILE $INSTANA_INSTALL_PROFILE)

keychain_path=""
if test -f "$custom_sp_keychain_path"; then
   echo ... instana core config ... using custom sp keychain ... $custom_sp_keychain
   keychain_path=$custom_keychain_path

elif test -f "$sp_keychain_path"; then
   echo ... instana core config ... using sp keychain ... $sp_keychain_path
   keychain_path=$sp_keychain_path;

else
   echo ... instana core config ... no service provider keychain
fi

if test "$keychain_path"; then
cat << EOF >> $outpath

# SAML/OIDC configuration
serviceProviderConfig:
  # Password for the key/cert file
  keyPassword: $CORE_CONFIG_SP_KEY_PASSWORD

  # The combined key/cert file
  pem: |
`cat $keychain_path | awk '$0 {sub(/^[ \t]+/, "", $0); sub(/[ \t]+$/, "", $0); printf("    %s\n", $0)}' -`
EOF
fi

#
# proxy config
#
if test "$CORE_CONFIG_PROXY_ENABLE"; then

cat << EOF >> $outpath

# Required if a proxy is configured that needs authentication
proxyConfig:
  # Proxy user
  user: ${CORE_CONFIG_PROXY_USER}
  # Proxy password
  password: ${CORE_CONFIG_PROXY_PASSWORD}
EOF

fi

#
# email smtp config
#
if test $CORE_CONFIG_EMAIL_ENABLE_SMTP; then
cat << EOF >> $outpath

emailConfig:
  # Required if SMTP is used for sending e-mails and authentication is required
  smtpConfig:
    user: $CORE_CONFIG_EMAIL_SMTP_USER
    password: $CORE_CONFIG_EMAIL_SMTP_PASSWORD
EOF
fi

#
# email ses config
#
if test $CORE_CONFIG_EMAIL_ENABLE_SES; then
cat << EOF >> $outpath

  # Required if using for sending e-mail.
  # Credentials should be configured.
  # Not required if using IRSA on EKS.
  sesConfig:
    accessKeyId: $CORE_CONFIG_AWS_IAM_ACCESS_KEY_ID
    secretAccessKey: $CORE_CONFIG_AWS_IAM_SECRET_KEY
EOF
fi

#
# custom ca certificates
#
ca_bundle=$(tls_file_path $CORE_CONFIG_CUSTOM_CA_BUNDLE_FILE $INSTANA_INSTALL_PROFILE)

if test -f "$ca_bundle"; then
echo core config ... including custom ca bundle $ca_bundle

cat << EOF >> $outpath
# Optional: You can add one or more custom CA certificates to the component trust stores
# in case internal systems (such as LDAP or alert receivers) which Instana talks to use a custom CA.
customCACert: |
`cat $ca_bundle | awk '$0 {}' -`
EOF

else
   echo ... instana core config ... no custom ca bundle
fi

# debug
if test $offline_mode; then
   online=""
   offline="offline"

else
   online="online"
fi

#
# datastore configs
#
cat << EOF >> $outpath

datastoreConfigs:
  beeInstanaConfig:
    user: beeinstana-user
    password: "${BEEINSTANA_ADMIN_PASS}"
  kafkaConfig:
    adminUser: strimzi-kafka-user
    adminPassword: "`if test $online; then ${KUBECTL} get secret strimzi-kafka-user  -n instana-kafka --template='{{index .data.password | base64decode}}'; else echo $offline; fi`"
    consumerUser: strimzi-kafka-user
    consumerPassword: "`if test $online; then ${KUBECTL} get secret strimzi-kafka-user  -n instana-kafka --template='{{index .data.password | base64decode}}'; else echo $offline; fi`"
    producerUser: strimzi-kafka-user
    producerPassword: "`if test $online; then ${KUBECTL} get secret strimzi-kafka-user  -n instana-kafka --template='{{index .data.password | base64decode}}'; else echo $offline; fi`"
  elasticsearchConfig:
    adminUser: elastic
    adminPassword: "`if test $online; then ${KUBECTL} get secret instana-es-elastic-user -n instana-elasticsearch -o go-template='{{.data.elastic | base64decode}}'; else echo $offline; fi`"
    user: elastic
    password: "`if test $online; then ${KUBECTL} get secret instana-es-elastic-user -n instana-elasticsearch -o go-template='{{.data.elastic | base64decode}}'; else echo $offline; fi`"
  postgresConfigs:
    - user: instanaadmin
      password: "`if test $online; then ${KUBECTL} get secret instanaadmin -n instana-postgres --template='{{index .data.password | base64decode}}'; else echo $offline; fi`"
      adminUser: instanaadmin
      adminPassword: "`if test $online; then ${KUBECTL} get secret instanaadmin -n instana-postgres --template='{{index .data.password | base64decode}}'; else echo $offline; fi`"
  cassandraConfigs:
    - user: instana-superuser
      password: "`if test $online; then ${KUBECTL} get secret instana-superuser -n instana-cassandra --template='{{index .data.password | base64decode}}'; else echo $offline; fi`"
      adminUser: instana-superuser
      adminPassword: "`if test $online; then ${KUBECTL} get secret instana-superuser -n instana-cassandra --template='{{index .data.password | base64decode}}'; else echo $offline; fi`"
  clickhouseConfigs:
    - user: "clickhouse-user"
      password: "${CLICKHOUSE_USER_PASS}"
      adminUser: "default"
      adminPassword: "${CLICKHOUSE_ADMIN_PASS}"
EOF

echo
echo deleting instana-core secret, namespace instana-core
if test $online; then
   $KUBECTL delete secret instana-core --namespace instana-core
else
   echo $offline
fi

echo
echo creating instana-core secret from $outpath, namespace instana-core
if test $online; then
   $KUBECTL create secret generic instana-core --namespace instana-core --from-file=config.yaml=$outpath
else
   echo $offline
fi
