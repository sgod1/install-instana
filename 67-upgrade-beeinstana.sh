#!/bin/bash

./install-beeinstana-operator.sh upgrade
./cr-beeinstana-patch.sh replace
./install-beeinstana-apply-patch.sh
