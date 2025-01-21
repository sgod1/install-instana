#!/bin/bash

./install-kafka-operator.sh upgrade 
./cr-kafka-patch.sh replace
./install-kafka-apply-patch.sh 

