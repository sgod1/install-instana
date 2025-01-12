#!/bin/bash

UPGRADE_VERSION=$1
COMPONENT=${2:-"set-upgrade-version-arg2"}

source ../instana.env

if test -z $UPGRADE_VERSION; then
echo Instana ugrade version argument required for upgrade, component $COMPONENT
exit 1
fi

echo upgrading $COMPONENT from instana version $INSTANA_VERSION to $UPGRADE_VERSION
