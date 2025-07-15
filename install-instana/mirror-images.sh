#!/bin/bash

source ../instana.env
source ./help-functions.sh

export PATH=".:$PATH"

mirror_home=$(get_mirror_home $INSTANA_VERSION)

echo mirror backend images, mirror home ... $mirror_home
img-backend-pull-images.sh
check_return_code $?

img-backend-tag-images.sh
check_return_code $?

img-backend-push-images.sh
check_return_code $?

echo mirror cert-manager images, mirror home ... $mirror_home
img-certmgr-pull-images.sh
check_return_code $?

img-certmgr-tag-images.sh
check_return_code $?

img-certmgr-push-images.sh
check_return_code $?

echo mirror datastore images, mirror home ... $mirror_home
img-datastore-pull-images.sh
check_return_code $?

img-datastore-tag-images.sh
check_return_code $?

img-datastore-push-images.sh
check_return_code $?

