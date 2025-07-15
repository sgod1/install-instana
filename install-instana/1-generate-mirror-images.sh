#!/bin/bash

source ./help-functions.sh

export PATH=".:$PATH"

img-backend-image-list.sh
check_return_code $?

img-datastore-image-list.sh
check_return_code $?

img-certmgr-image-list.sh
check_return_code $?
