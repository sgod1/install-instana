#!/bin/bash

# to skip hooks: "upgrade --no-hooks"
./install-zookeeper-operator.sh upgrade
./cr-zookeeper-patch.sh replace
./install-zookeeper-apply-patch.sh 

