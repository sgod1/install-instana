#!/bin/bash

./install-elasticsearch-operator.sh upgrade 
./cr-elasticsearch-patch.sh replace 
./install-elasticsearch-apply-patch.sh 
