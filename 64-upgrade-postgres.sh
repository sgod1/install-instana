#!/bin/bash

UPGRADE_VERSION=$1
COMPONENT="postgres"

./set-upgrade-version.sh $UPGRADE_VERSION $COMPONENT

./install-postgres-operator.sh upgrade $UPGRADE_VERSION
./cr-postgres-patch.sh replace $UPGRADE_VERSION
./install-postgres-apply-patch.sh $UPGRADE_VERSION

