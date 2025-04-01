#!/bin/bash

source ./help-functions.sh

export PATH=".:$PATH"

install-cassandra-operator.sh
check_return_code $?

install-cassandra-apply-cr.sh
check_return_code $?

