#!/bin/bash

source ../instana.env
source ./help-functions.sh

tenant_domain=$(instana_tenant_domain $INSTANA_UNIT_NAME $INSTANA_TENANT_NAME $INSTANA_BASE_DOMAIN)
agent_acceptor=$(instana_agent_acceptor $INSTANA_BASE_DOMAIN)

# todo: otel routes
otlp_grpc_acceptor=$(instana_otlp_grpc_acceptor $INSTANA_BASE_DOMAIN)
otlp_http_acceptor=$(instana_otlp_http_acceptor $INSTANA_BASE_DOMAIN)

if is_platform_ocp "$PLATFORM"; then
echo "Creating routes..."
${KUBECTL} create route passthrough ui-client-tenant --hostname=${tenant_domain} --service=gateway --port=https -n instana-core
${KUBECTL} create route passthrough ui-client-ssl --hostname=${INSTANA_BASE_DOMAIN} --service=gateway --port=https -n instana-core
${KUBECTL} create route passthrough acceptor  --hostname=${agent_acceptor}  --service=acceptor  --port=8600  -n instana-core
fi
