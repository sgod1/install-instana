#!/bin/bash

# to skip hooks: "upgrade --no-hooks"
./install-clickhouse-operator.sh upgrade
./cr-clickhouse-patch.sh replace
./install-clickhouse-apply-patch.sh
