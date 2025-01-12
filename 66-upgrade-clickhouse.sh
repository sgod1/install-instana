#!/bin/bash

UPGRADE_VERSION=$1
COMPONENT="clickhouse"

./set-upgrade-version.sh $UPGRADE_VERSION $COMPONENT

./install-clickhouse-operator.sh upgrade $UPGRADE_VERSION
./cr-clickhouse-patch.sh replace $UPGRADE_VERSION
./install-clickhouse-apply-patch.sh $UPGRADE_VERSION

