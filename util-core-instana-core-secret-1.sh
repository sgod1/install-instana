#!/bin/bash

source ../instana.env
source ./help-functions.sh

INSTALL_HOME=$(get_install_home)
MANIFEST_HOME=$(get_manifest_home)

CORE_CONFIG="$MANIFEST_HOME/core-config.yaml"

replace_manifest=${1:-"noreplace"}

check_replace_manifest $CORE_CONFIG $replace_manifest

# create core-config.yaml
echo writing core config to $CORE_CONFIG
echo

cat << EOF > $CORE_CONFIG
# core config.yaml

# Diffie-Hellman parameters to use
#dhParams: |
#  -----BEGIN DH PARAMETERS-----
#  <snip/>
#  -----END DH PARAMETERS-----

# The repository password for accessing the Instana agent repository.
# Use the download key that you received from us
repositoryPassword: ${DOWNLOAD_KEY:-"instana-download-key"}

# The sales key you received from IBM
salesKey: ${SALES_KEY:-"instana-sales-key"}

# Seed for creating crypto tokens. Pick a random 12 char string
tokenSecret: ${CORE_TOKEN_SECRET:-"mytoken"}

# Configuration for raw spans storage
storageConfigs:
  rawSpans:

EOF

if compare_values "$RAW_SPANS_TYPE" "$RAW_SPANS_TYPE_S3"; then
cat << EOF >> $CORE_CONFIG
    # Required if using S3 or compatible storage bucket.
    # Credentials should be configured.
    # Not required if IRSA on EKS is used.
    s3Config:
      accessKeyId: ${AWS_IAM_ACCESS_KEY_ID:-"aws:iam:acccess-key:1"}
      secretAccessKey: ${AWS_IAM_SECRET_KEY:-"aws:iam:secret-key"}

EOF
fi

if compare_values "$RAW_SPANS_TYPE" "$RAW_SPANS_TYPE_GCP"; then
cat << EOF >> $CORE_CONFIG
    # Required if using Google Cloud Storage.
    # Credentials should be configured.
    # Not required if GKE with workload identity is used.
    gcloudConfig:
      serviceAccountKey: ${GCP_SERVICE_ACCOUNT_KEY:-"gcp:service-account-key"}

EOF
fi

cat << EOF >> $CORE_CONFIG
# SAML/OIDC configuration
#serviceProviderConfig:
#  # Password for the key/cert file
#  keyPassword: mykeypass
#  # The combined key/cert file
#  pem: |
#    -----BEGIN RSA PRIVATE KEY-----
#    <snip/>
#    -----END RSA PRIVATE KEY-----
#    -----BEGIN CERTIFICATE-----
#    <snip/>
#    -----END CERTIFICATE-----

# Required if a proxy is configured that needs authentication
#proxyConfig:
#  # Proxy user
#  user: ${PROXY_USER:-"proxy-user"}
#  # Proxy password
#  password: ${PROXY_PASSWORD:-"proxy-password"}

#emailConfig:
#  # Required if SMTP is used for sending e-mails and authentication is required
#  smtpConfig:
#    user: ${SMTP_USER:-"smtp-user"}
#    password: ${SMTP_PASSWORD:-"smtp-password"}

#  # Required if using for sending e-mail.
#  # Credentials should be configured.
#  # Not required if using IRSA on EKS.
#  sesConfig:
#    accessKeyId: ${AWS_IAM_ACCESS_KEY_ID:-"aws:iam:access-key"}
#    secretAccessKey: ${AWS_IAM_SECRET_KEY:-"aws:iam:secret-key"}

# Optional: You can add one or more custom CA certificates to the component trust stores
# in case internal systems (such as LDAP or alert receivers) which Instana talks to use a custom CA.
#customCACert: |
#  -----BEGIN CERTIFICATE-----
#  <snip/>
#  -----END CERTIFICATE-----
#  # Add more certificates if you need
#  # -----BEGIN CERTIFICATE-----
#  # <snip/>
#  # -----END CERTIFICATE-----

datastoreConfigs:
  beeInstanaConfig:
    user: beeinstana-user
    password: "${BEEINSTANA_ADMIN_PASS:-"beeinstana-admin-pass"}"
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
    - user: "${CLICKHOUSE_USER}"
      password: "${CLICKHOUSE_USER_PASS}"
      adminUser: "${CLICKHOUSE_USER}"
      adminPassword: "${CLICKHOUSE_USER_PASS}"
EOF

echo creating instana-core secret from $CORE_CONFIG, namespace instana-core
echo

if compare_values "$replace_manifest" "replace"; then
   echo replacing instana-core secret, namespace instana-core
   $KUBECTL delete secret instana-core --namespace instana-core
fi

$KUBECTL create secret generic instana-core --namespace instana-core --from-file=config.yaml=$CORE_CONFIG
