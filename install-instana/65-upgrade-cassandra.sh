#!/bin/bash

# to skip hooks: "upgrade --no-hooks"
./install-cassandra-operator.sh upgrade
./cr-cassandra-patch.sh replace
./install-cassandra-apply-patch.sh

