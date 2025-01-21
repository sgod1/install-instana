#!/bin/bash

./install-clickhouse-operator.sh upgrade
./cr-clickhouse-patch.sh replace
./install-clickhouse-apply-patch.sh
