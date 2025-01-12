#!/bin/bash

UPGRADE_VERSION=$1
COMPONENT="cassandra"

./set-upgrade-version.sh $UPGRADE_VERSION $COMPONENT

./install-cassandra-operator.sh upgrade $UPGRADE_VERSION
./cr-cassandra-patch.sh replace $UPGRADE_VERSION
./install-cassandra-apply-patch.sh $UPGRADE_VERSION

