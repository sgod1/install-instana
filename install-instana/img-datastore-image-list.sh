#!/bin/bash

source ../instana.env
source ./help-functions.sh
source ./install.env

export PATH=".:$PATH"

generate-datastore-image-list.sh
check_return_code $?
