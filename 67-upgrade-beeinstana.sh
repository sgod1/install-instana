#!/bin/bash

UPGRADE_VERSION=$1
COMPONENT="beeinstana"

./set-upgrade-version.sh $UPGRADE_VERSION $COMPONENT

./install-beeinstana-operator.sh upgrade $UPGRADE_VERSION
./cr-beeinstana-patch.sh replace $UPGRADE_VERSION
./install-beeinstana-apply-patch.sh $UPGRADE_VERSION

