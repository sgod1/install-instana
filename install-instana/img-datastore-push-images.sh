#!/bin/bash

source ../instana.env
source ./help-functions.sh
source ./install.env

export PATH=".:$PATH"

MIRROR_HOME=$(get_make_mirror_home $INSTANA_VERSION)

image_list=${MIRROR_HOME}/${INSTANA_DATASTORE_IMAGE_LIST_FILE}

push-images.sh $image_list
check_return_code $?
