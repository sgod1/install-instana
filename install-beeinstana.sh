#!/bin/bash

source ./help-functions.sh

PATH=".:$PATH"

install-beeinstana-operator.sh
check_return_code $?

install-beeinstana-apply-cr.sh
check_return_code $?

