#!/bin/bash

./install-zookeeper-operator.sh upgrade
./cr-zookeeper-patch.sh replace
./install-zookeeper-apply-patch.sh 

