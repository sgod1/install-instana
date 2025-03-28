#!/bin/bash

source ./help-functions.sh

install-elasticsearch-operator.sh
check_return_code $?

install-elasticsearch-apply-cr.sh
check_return_code $?

