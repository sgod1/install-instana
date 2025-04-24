#!/bin/bash

source ../instana.env
source ./install.env
source ./help-functions.sh

# extend path with current dir
PATH=".:$PATH"

rc_config=0

function tls_file_path() {
   local filename=$1
   local profile=$2

   local tls_home=$(get_tls_home)
   local ver=$INSTANA_VERSION

   format_file_path $tls_home $filename $profile
}

#
# main
#

# crypto prefix: sp or custom
crypto_prefix=${1:-"sp"}

install_home=$(get_install_home)
manifest_home=$(get_manifest_home)

check_replace_manifest $config_file $replace_manifest

# service provider keychain
core-sp-tls-keychain.sh $crypto_prefix
check_return_code $?

CORE_CONFIG_FILE="core-config.yaml"
outpath=$(format_file_path $manifest_home $CORE_CONFIG_FILE $INSTANA_INSTALL_PROFILE)

# core-config.yaml
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
sp_keychain_path=$(tls_file_path "${crypto_prefix}-${CORE_CONFIG_SP_KEYCHAIN_FILE}" $INSTANA_INSTALL_PROFILE)

if test -f "$sp_keychain_path"; then
echo ... instana core config ... using service provider keychain ... $sp_keychain_path

cat << EOF >> $outpath

# SAML/OIDC configuration
serviceProviderConfig:

  # Password for the key/cert file
  keyPassword: $CORE_CONFIG_SP_KEY_PASSWORD

  # The combined key/cert file
  pem: |
`cat $sp_keychain_path | awk '$0 {sub(/^[ \t]+/, "", $0); sub(/[ \t]+$/, "", $0); printf("    %s\n", $0)}' -`
EOF

else
echo ... instana core config ... no service provider keychain

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
if test $CORE_CONFIG_EMAIL_SMTP_ENABLE; then
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
if test $CORE_CONFIG_EMAIL_AWS_SES_ENABLE; then
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
    adminPassword: "`${KUBECTL} get secret strimzi-kafka-user  -n instana-kafka --template='{{index .data.password | base64decode}}'`"
    consumerUser: strimzi-kafka-user
    consumerPassword: "`${KUBECTL} get secret strimzi-kafka-user  -n instana-kafka --template='{{index .data.password | base64decode}}'`"
    producerUser: strimzi-kafka-user
    producerPassword: "`${KUBECTL} get secret strimzi-kafka-user  -n instana-kafka --template='{{index .data.password | base64decode}}'`"

  elasticsearchConfig:
    adminUser: elastic
    adminPassword: "`${KUBECTL} get secret instana-es-elastic-user -n instana-elasticsearch -o go-template='{{.data.elastic | base64decode}}'`"
    user: elastic
    password: "`${KUBECTL} get secret instana-es-elastic-user -n instana-elasticsearch -o go-template='{{.data.elastic | base64decode}}'`"

  postgresConfigs:
    - user: instanaadmin
      password: "`${KUBECTL} get secret instanaadmin -n instana-postgres --template='{{index .data.password | base64decode}}'`"
      adminUser: instanaadmin
      adminPassword: "`${KUBECTL} get secret instanaadmin -n instana-postgres --template='{{index .data.password | base64decode}}'`"

  cassandraConfigs:
    - user: instana-superuser
      password: "`${KUBECTL} get secret instana-superuser -n instana-cassandra --template='{{index .data.password | base64decode}}'`"
      adminUser: instana-superuser
      adminPassword: "`${KUBECTL} get secret instana-superuser -n instana-cassandra --template='{{index .data.password | base64decode}}'`"

  clickhouseConfigs:
    - user: "clickhouse-user"
      password: "${CLICKHOUSE_USER_PASS}"
      adminUser: "default"
      adminPassword: "${CLICKHOUSE_ADMIN_PASS}"
EOF

echo
echo deleting instana-core secret, namespace instana-core

$KUBECTL delete secret instana-core --namespace instana-core

echo
echo creating instana-core secret from $outpath, namespace instana-core

$KUBECTL create secret generic instana-core --namespace instana-core --from-file=config.yaml=$outpath
