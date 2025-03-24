#!/bin/bash

source ./help-functions.sh

export PATH=".:$PATH"

install-postgres-operator.sh
check_return_code $?

install-postgres-apply-cr.sh
check_return_code $?
