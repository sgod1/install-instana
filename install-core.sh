#!/bin/bash

source ./help-functions.sh

PATH=".:$PATH"

install-core-apply-cr.sh
check_return_code $?
