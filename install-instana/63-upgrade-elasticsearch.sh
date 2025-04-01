#!/bin/bash

# to skip hooks: "upgrade --no-hooks"
./install-elasticsearch-operator.sh upgrade 
./cr-elasticsearch-patch.sh replace 
./install-elasticsearch-apply-patch.sh 
