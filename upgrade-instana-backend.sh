#!/bin/bash

source ../instana.env
source ./release.env

source ./help-functions.sh

INSTALL_HOME=$(get_install_home)

# instana semantic version
semver=${__instana_sem_version[${INSTANA_VERSION}]}

echo "Upgrading instana backend to instana semantic version $semver, instana plugin $INSTANA_PLUGIN_VERSION"

set -x

${INSTALL_HOME}/bin/kubectl-instana versions update --download-key="$DOWNLOAD_KEY" --instana-version "$semver"
