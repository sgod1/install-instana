#!/bin/bash

# to skip hooks: "upgrade --no-hooks"
./install-postgres-operator.sh upgrade 
./cr-postgres-patch.sh replace 
./install-postgres-apply-patch.sh 

