#!/bin/bash

source ./help-functions.sh

install-core-apply-cr.sh
check_return_code $?
