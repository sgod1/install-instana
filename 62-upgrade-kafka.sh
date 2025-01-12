#!/bin/bash

UPGRADE_VERSION=$1
COMPONENT="kafka"

./set-upgrade-version.sh $UPGRADE_VERSION $COMPONENT

./install-kafka-operator.sh upgrade $UPGRADE_VERSION
./cr-kafka-patch.sh replace $UPGRADE_VERSION
./install-kafka-apply-patch.sh $UPGRADE_VERSION

