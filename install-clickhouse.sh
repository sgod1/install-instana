#!/bin/bash

source ./help-functions.sh

bin_home=$(get_bin_home)
export PATH=".:$bin_home:$PATH"

install-clickhouse-operator.sh
check_return_code $?

install-clickhouse-apply-cr.sh
check_return_code $?

