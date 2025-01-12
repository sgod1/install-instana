#!/bin/bash

UPGRADE_VERSION=$1
COMPONENT="zookeeper"

./set-upgrade-version.sh $UPGRADE_VERSION $COMPONENT

./install-zookeeper-operator.sh upgrade $UPGRADE_VERSION
./cr-zookeeper-patch.sh replace $UPGRADE_VERSION
./install-zookeeper-apply-patch.sh $UPGRADE_VERSION

