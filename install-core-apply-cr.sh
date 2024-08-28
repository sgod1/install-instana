#!/bin/bash

source ../instana.env
source ./help-functions.sh

MANIFEST_HOME=$(get_manifest_home)

# download license file

# create core instana-tls secret for ingress configuration
#if test $CORE_TLS_CERTIFICATE_GENERATE == "YES"; then
echo "Generating SSL certificates tls.csr/tls.key ..."
openssl genrsa -out ca.key 2048

openssl req -new -x509 -days 365 -key ca.key \
        -subj "/C=CN/ST=GD/L=SZ/O=IBM/CN=IBM Root CA" -out ca.crt

openssl req -newkey rsa:2048 -nodes -keyout tls.key \
        -subj "/C=CN/ST=GD/L=SZ/O=IBM./CN=*.${INSTANA_BASE_DOMAIN}" -out tls.csr

openssl x509 -req -extfile <(printf "subjectAltName=DNS:${INSTANA_BASE_DOMAIN},DNS:${INSTANA_TENANT_DOMAIN},DNS:${INSTANA_AGENT_ACCEPTOR},DNS:${INSTANA_OTLP_GRPC_ACCEPTOR},DNS:${INSTANA_OTLP_HTTP_ACCEPTOR}") \
        -days 365 -in tls.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out tls.crt

$KUBECTL create secret tls instana-tls --namespace instana-core \
    --cert=tls.crt \
    --key=tls.key
#fi

# diffie-helman parameters (optional)

# saml/oidc key pair (optional)

# create core-config.yaml
CORE_CONFIG=$MANIFEST_HOME/core-config.yaml

cat << EOF > $CORE_CONFIG
# Diffie-Hellman parameters to use (optional)
#dhParams: |
#  -----BEGIN DH PARAMETERS-----
#  <snip/>
#  -----END DH PARAMETERS-----

# The repository password for accessing the Instana agent repository.
# Use the download key that you received from us
# sg: this may not work, can not access instana agent repository
repositoryPassword: $DOWNLOAD_KEY

# The sales key you received from us
salesKey: $SALES_KEY

# Seed for creating crypto tokens. Pick a random 12 char string
tokenSecret: $CORE_TOKEN_SECRET

# Configuration for raw spans storage
storageConfigs:
#  rawSpans:
#    # Required if using S3 or compatible storage bucket.
#    # Credentials should be configured.
#    # Not required if IRSA on EKS is used.
#    s3Config:
#      accessKeyId: ...
#      secretAccessKey: ...
#    # Required if using Google Cloud Storage.
#    # Credentials should be configured.
#    # Not required if GKE with workload identity is used.
#    gcloudConfig:
#      serviceAccountKey: ...

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
#  user: myproxyuser
#  # Proxy password
#  password: my proxypassword

#emailConfig:
#  # Required if SMTP is used for sending e-mails and authentication is required
#  smtpConfig:
#    user: mysmtpuser
#    password: mysmtppassword
#  # Required if using for sending e-mail.
#  # Credentials should be configured.
#  # Not required if using IRSA on EKS.
#  sesConfig:
#    accessKeyId: ...
#    secretAccessKey: ...

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
    - user: "${CLICKHOUSE_USER}"
      password: "${CLICKHOUSE_USER_PASS}"
      adminUser: "${CLICKHOUSE_USER}"
      adminPassword: "${CLICKHOUSE_USER_PASS}"
EOF

# create instana-core secret
echo creating instana-core secret, namespace instana-core
$KUBECTL create secret generic instana-core --namespace instana-core --from-file=config.yaml=$CORE_CONFIG

# apply instana-core manifest
echo applying core manifest $MANIFEST_HOME/$MANIFEST_FILENAME_CORE, namespace instna-core
$KUBECTL apply -n instana-core -f $MANIFEST_HOME/$MANIFEST_FILENAME_CORE
