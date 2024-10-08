#!/bin/bash

source ../instana.env
source ./help-functions.sh

# pass "disable_webhook" argument to disable webhook
DISABLE_WEBHOOK="disable_webhook"
ENABLE_WEBHOOK="enable_webhook"
webhook_startup=${1:-"$ENABLE_WEBHOOK"}

# pass custom_webhook_cert to use custom cert
CUSTOM_WEBHOOK_CERT="custom_webhook_cert"
NO_CUSTOM_WEBHOOK_CERT="no_custom_cert"
custom_webhook_cert=${1:-$NO_CUSTOM_WEBHOOK_CERT}

CHART_HOME=$(get_chart_home)
MANIFEST_HOME=$(get_manifest_home)

CHART=$CHART_HOME/cass-operator-0.45.2.tgz

SCC=$MANIFEST_HOME/$MANIFEST_FILENAME_CASSANDRA_SCC

if is_platform_ocp $PLATFORM && test ! -f $SCC; then
   echo cassandra scc $SCC not found
   exit 1
fi

if is_platform_ocp $PLATFORM; then
   echo applying cassandra scc $SCC
   $KUBECTL apply -f $SCC -n instana-cassandra
fi

if test ! -f $CHART; then
   echo helm chart $CHART not found
   exit 1
fi

# admission webhook, enabled by default
set_admission_webhook="--set admissionWebhooks.enabled=true"

# custom webhook cert
set_custom_webhook_cert=""

if compare_values $webhook_startup $DISABLE_WEBHOOK; then
echo "admission webhook disabled..."
set_admission_webhook="--set admissionWebhooks.enabled=false"

elif compare_values $custom_webhook_cert $CUSTOM_WEBHOOK_CERT; then

# use custom webhook cert
echo "using custom webhook cert..."

# issuer
echo ""
echo "creating issuer cass-operator-selfsigned-issuer, namespace instana-cassandra"

cat <<EOF | $KUBECTL apply -f -
apiVersion: cert-manager.io/v1
kind: Issuer
metadata:
  name: cass-operator-selfsigned-issuer
  namespace: instana-cassandra
spec:
  selfSigned: {}
EOF

# webhook certificate
WEBHOOK_CERT_NAME=cass-operator-serving-cert

echo ""
echo "creating webhook certificate $WEBHOOK_CERT_NAME, namespace instana-cassandra"

cat <<EOF | $KUBECTL apply -f -
apiVersion: v1
kind: List
items:
- apiVersion: cert-manager.io/v1
  kind: Certificate
  metadata:
    name: $WEBHOOK_CERT_NAME
    namespace: instana-cassandra
  spec:
    dnsNames:
    - cass-operator-webhook-service.instana-cassandra.svc
    - cass-operator-webhook-service.instana-cassandra.svc.cluster.local
    issuerRef:
      kind: Issuer
      name: cass-operator-selfsigned-issuer
    secretName: cass-operator-webhook-server-cert
EOF

set_custom_webhook_cert="--set admissionWebhooks.customCertificate=instana-cassandra/$WEBHOOK_CERT_NAME"
fi

echo ""
echo installing cassandra operator helm chart $CHART
echo ""

set -x

helm install cassandra-operator -n instana-cassandra $CHART \
   $set_admission_webhook $set_custom_webhook_cert \
   --set securityContext.runAsNonRoot=true \
   --set securityContext.runAsUser=999 \
   --set securityContext.runAsGroup=999 \
   --set image.registry=$PRIVATE_REGISTRY \
   --set image.repository="self-hosted-images/3rd-party/operator/cass-operator" \
   --set image.tag="1.18.2_v0.12.0" \
   --set imagePullSecrets[0].name="instana-registry" \
   --set appVersion="1.18.2" \
   --set imageConfig.systemLogger="$PRIVATE_REGISTRY/self-hosted-images/3rd-party/datastore/system-logger:1.18.2_v0.3.0" \
   --set imageConfig.k8ssandraClient="$PRIVATE_REGISTRY/self-hosted-images/3rd-party/datastore/k8ssandra-client:0.2.2_v0.3.0" \
   --set imageConfig.configBuilder="$PRIVATE_REGISTRY/datastax/cass-config-builder:1.0-ubi7" 
