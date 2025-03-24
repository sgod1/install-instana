#!/bin/bash

source ../instana.env
source ./install.env
source ./help-functions.sh
source ./datastore-images.env; check_return_code $?

# install, upgrade
helm_action=${1:-"install"}

bin_home=$(get_bin_home)
PATH=".:$bin_home:$PATH"

# pass "disable_webhook" argument to disable webhook
DISABLE_WEBHOOK="disable_webhook"
ENABLE_WEBHOOK="enable_webhook"
webhook_startup=${1:-"$ENABLE_WEBHOOK"}

# pass custom_webhook_cert to use custom cert
CUSTOM_WEBHOOK_CERT="custom_webhook_cert"
NO_CUSTOM_WEBHOOK_CERT="no_custom_cert"
custom_webhook_cert=${1:-$NO_CUSTOM_WEBHOOK_CERT}

CHART_HOME=$(get_chart_home)
CHART_HOME=${CHART_HOME}/${INSTANA_VERSION}
mkdir -p ${CHART_HOME}

CHART=$CHART_HOME/cass-operator-${CASSANDRA_OPERATOR_CHART_VERSION}.tgz

MANIFEST_HOME=$(get_manifest_home)
SCC=$(format_file_path $MANIFEST_HOME $MANIFEST_FILENAME_CASSANDRA_SCC $INSTANA_INSTALL_PROFILE $INSTANA_VERSION)

if is_platform_ocp $PLATFORM && test ! -f $SCC; then
   echo cassandra scc $SCC not found
   exit 1
fi

if is_platform_ocp $PLATFORM; then
   echo applying cassandra scc $SCC
   $KUBECTL -n instana-cassandra adm policy add-scc-to-user privileged -z cassandra-operator-cass-operator
   $KUBECTL -n instana-cassandra adm policy add-scc-to-user privileged -z default

   #$KUBECTL apply -f $SCC -n instana-cassandra
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

cassandra_operator_img_repo=`echo $CASSANDRA_OPERATOR_IMG | cut -d : -f 1 -`
cassandra_operator_img_tag=`echo $CASSANDRA_OPERATOR_IMG | cut -d : -f 2 -`

helm ${helm_action} cassandra-operator -n instana-cassandra $CHART \
   $set_admission_webhook $set_custom_webhook_cert \
   --set securityContext.runAsNonRoot=true \
   --set securityContext.runAsUser=999 \
   --set securityContext.runAsGroup=999 \
   --set image.registry=$PRIVATE_REGISTRY \
   --set image.repository="$cassandra_operator_img_repo" \
   --set image.tag="$cassandra_operator_img_tag" \
   --set imagePullSecrets[0].name="instana-registry" \
   --set appVersion="$CASSANDRA_OPERATOR_CHART_APP_VERSION" \
   --set imageConfig.systemLogger="$PRIVATE_REGISTRY/$CASSANDRA_SYSTEM_LOGGER_IMG" \
   --set imageConfig.k8ssandraClient="$PRIVATE_REGISTRY/$CASSANDRA_K8S_CLIENT_IMG" \
   --wait --timeout 60m0s

