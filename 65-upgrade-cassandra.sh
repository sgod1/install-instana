#!/bin/bash

./install-cassandra-operator.sh upgrade
./cr-cassandra-patch.sh replace
./install-cassandra-apply-patch.sh

