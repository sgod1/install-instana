#!/bin/bash

source ../instana.env
source ./help-functions.sh

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
