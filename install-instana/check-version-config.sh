#!/bin/bash

source ../instana.env
source ./release.env

# check configured versions
check_version_compat "$INSTANA_PLUGIN_VERSION" "$INSTANA_VERSION"

# instana semantic version
echo instana semantic version: ${__instana_sem_version["${INSTANA_VERSION}"]}

# check installed plugin
if test -f ./gen/bin/kubectl-instana; then
./gen/bin/kubectl-instana -v
else
echo kubectl-instana plugin not installed
fi

