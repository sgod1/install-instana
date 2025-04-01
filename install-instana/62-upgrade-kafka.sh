#!/bin/bash

# to skip hooks: "upgrade --no-hooks"
./install-kafka-operator.sh upgrade 
./cr-kafka-patch.sh replace
./install-kafka-apply-patch.sh 

