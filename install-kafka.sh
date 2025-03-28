#!/bin/bash

source ./help-functions.sh

bin_home=$(get_bin_home)
export PATH=".:$bin_home:$PATH"

install-kafka-operator.sh
check_return_code $?

install-kafka-apply-cr.sh
check_return_code $?

