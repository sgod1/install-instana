#!/bin/bash

source ../instana.env
source ./help-functions.sh

if is_platform_ocp "$PLATFORM"; then
echo "Creating routes..."
${KUBECTL} create route passthrough ui-client-tenant --hostname=${INSTANA_TENANT_DOMAIN} --service=gateway --port=https -n instana-core
${KUBECTL} create route passthrough ui-client-ssl --hostname=${INSTANA_BASE_DOMAIN} --service=gateway --port=https -n instana-core
${KUBECTL} create route passthrough acceptor  --hostname=${INSTANA_AGENT_ACCEPTOR}  --service=acceptor  --port=8600  -n instana-core
fi
