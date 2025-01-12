#!/bin/bash

UPGRADE_VERSION=$1
COMPONENT="elasticsearch"

./set-upgrade-version.sh $UPGRADE_VERSION $COMPONENT

./install-elasticsearch-operator.sh upgrade $UPGRADE_VERSION
./cr-elasticsearch-patch.sh replace $UPGRADE_VERSION
./install-elasticsearch-apply-patch.sh $UPGRADE_VERSION

