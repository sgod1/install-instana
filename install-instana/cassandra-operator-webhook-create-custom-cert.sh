#!/bin/bash

source ../instana.env
source ./help-functions.sh

# this script deploys cassandra operator webhook issuer and certificate
# to test certificate manager

namespace=${1:-"instana-cassandra"}

# issuer
echo ""
echo "creating issuer cass-operator-selfsigned-issuer, namespace $namespace"

cat <<EOF | $KUBECTL apply -f -
apiVersion: cert-manager.io/v1
kind: Issuer
metadata:
  name: cass-operator-selfsigned-issuer
  namespace: $namespace
spec:
  selfSigned: {}
EOF

# webhook certificate
WEBHOOK_CERT_NAME=cass-operator-serving-cert

echo ""
echo "creating webhook certificate $WEBHOOK_CERT_NAME, namespace $namespace"

cat <<EOF | $KUBECTL apply -f -
apiVersion: v1
kind: List
items:
- apiVersion: cert-manager.io/v1
  kind: Certificate
  metadata:
    name: $WEBHOOK_CERT_NAME
    namespace: $namespace
  spec:
    dnsNames:
    - cass-operator-webhook-service.$namespace.svc
    - cass-operator-webhook-service.$namespace.svc.cluster.local
    issuerRef:
      kind: Issuer
      name: cass-operator-selfsigned-issuer
    secretName: cass-operator-webhook-server-cert
EOF
