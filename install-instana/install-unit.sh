#!/bin/bash

source ./help-functions.sh

PATH=".:$PATH"

install-unit-apply-cr.sh
check_return_code $?
