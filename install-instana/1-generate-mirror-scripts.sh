#!/bin/bash

source ../instana.env
source ./help-functions.sh
source ./install.env

function write_pull_image_script() {
   local image_list_file=$1
   local script_file=$2
   local anonymous=$3

   echo writing pull image script to $script_file

   #
   # do not pass $PODMAN_TLS_VERIFY to login to the mothership
   # do not pass $PODMAN_TLS_VERIFY to pull from the mothership
   #

   /usr/bin/awk -v ANONYMOUS=$anonymous '
   BEGIN { 
      print "#!/bin/bash" 
      print "source ../../../install.env"
      print "source ../../../../instana.env"
      print "if [[ $PODMAN_HTTP_PROXY ]]; then export HTTP_PROXY=$PODMAN_HTTP_PRXY; fi"
      print "if [[ $PODMAN_HTTPS_PROXY ]]; then export HTTPS_PROXY=$PODMAN_HTTPS_PRXY; fi"
      if (ANONYMOUS=="") print "$PODMAN login --username _ --password $DOWNLOAD_KEY $INSTANA_REGISTRY; rc=$?; if [[ $rc > 0 ]]; then echo error: login to $INSTANA_REGISTRY failed, rc=$rc; exit $rc; fi"
      print "set -x"
   }
   NF > 0 && $0 !~ /^#/ { printf("$PODMAN pull %s; rc=$?; if [[ $rc > 0 ]]; then echo error: image pull %s failed, rc=$rc; exit $rc; fi\n", $0, $0) } ' $image_list_file > $script_file

   chmod +x $script_file
}

function write_tag_image_script() {
   local image_list_file=$1
   local script_file=$2

   echo writing tag image script to $script_file

   /usr/bin/awk -v INSTANA_REGISTRY=$INSTANA_REGISTRY '
   BEGIN {
      print "#!/bin/bash" 
      print "source ../../../install.env"
      print "source ../../../../instana.env"
      print "set -x"
   }
   NF > 0 && $0 !~ /^#/ && $0 ~ /artifact-public.instana.io/ { sub("--platform linux/amd64", ""); printf("$PODMAN tag %s", $0); sub(INSTANA_REGISTRY, "$PRIVATE_REGISTRY"); printf(" %s; rc=$?; if [[ $rc > 0 ]]; then echo error: image tag %s failed, rc=$rc; exit $rc; fi\n", $0, $0) }
   ' $image_list_file > $script_file

   chmod +x $script_file
}

function write_push_image_script() {
   local image_list_file=$1
   local script_file=$2

   echo writing push image script to $script_file

   #
   # pass $PODMAN_TLS_VERIFY to login and push into private registry
   #

   /usr/bin/awk -v INSTANA_REGISTRY=$INSTANA_REGISTRY '
   BEGIN { 
      print "#!/bin/bash" 
      print "source ../../../install.env"
      print "source ../../../../instana.env"
      print "$PODMAN login $PODMAN_TLS_VERIFY --username $PRIVATE_REGISTRY_USER --password $PRIVATE_REGISTRY_PASSWORD $PRIVATE_DOCKER_SERVER; rc=$?; if [[ $rc > 0 ]]; then echo error: failed to login to $PRIVATE_DOCKER_SERVER, rc=$rc; exit $rc; fi"
      print "set -x"
   }
   NF > 0 && $0 !~ /^#/ && $0 ~ /artifact-public.instana.io/ { sub("--platform linux/amd64", ""); sub(INSTANA_REGISTRY, "$PRIVATE_REGISTRY"); printf("$PODMAN push $PODMAN_TLS_VERIFY %s; rc=$?; if [[ $rc > 0 ]]; then echo error: image push %s failed, rc=$rc; exit $rc; fi\n", $0, $0) }
   ' $image_list_file > $script_file

   chmod +x $script_file
}

function print_mirror_header() {
   local component=$1
   echo ""
   echo writing $component mirror scripts...
   echo ""
}

#
# main
#

# pass "run" argument to run scripts
run=${1:-"norun"}

MIRROR_HOME=$(get_make_mirror_home $INSTANA_VERSION)

#
# instana backend
#
print_mirror_header "backend"

./generate-backend-image-list.sh 
check_return_code $?

image_list=${MIRROR_HOME}/${INSTANA_BACKEND_IMAGE_LIST_FILE}
pull_script=${MIRROR_HOME}/$PULL_BACKEND_IMAGES_SCRIPT
push_script=${MIRROR_HOME}/$PUSH_BACKEND_IMAGES_SCRIPT
tag_script=${MIRROR_HOME}/$TAG_BACKEND_IMAGES_SCRIPT

write_pull_image_script $image_list $pull_script
check_return_code $?

write_tag_image_script $image_list $tag_script
check_return_code $?

write_push_image_script $image_list $push_script
check_return_code $?

#
# datastores
#
print_mirror_header "datastore"

./generate-datastore-image-list.sh
check_return_code $?

image_list=${MIRROR_HOME}/${INSTANA_DATASTORE_IMAGE_LIST_FILE}
pull_script=${MIRROR_HOME}/$PULL_DATASTORE_IMAGES_SCRIPT
push_script=${MIRROR_HOME}/$PUSH_DATASTORE_IMAGES_SCRIPT
tag_script=${MIRROR_HOME}/$TAG_DATASTORE_IMAGES_SCRIPT

write_pull_image_script $image_list $pull_script
check_return_code $?

write_tag_image_script $image_list $tag_script
check_return_code $?

write_push_image_script $image_list $push_script
check_return_code $?

#
# cert manager
#
print_mirror_header "cert-manager"

./generate-certmgr-image-list.sh 
check_return_code $?

image_list=${MIRROR_HOME}/${CERT_MGR_IMAGE_LIST_FILE}
pull_script=${MIRROR_HOME}/$PULL_CERT_MGR_IMAGES_SCRIPT
push_script=${MIRROR_HOME}/$PUSH_CERT_MGR_IMAGES_SCRIPT
tag_script=${MIRROR_HOME}/$TAG_CERT_MGR_IMAGES_SCRIPT

#write_pull_image_script $image_list $pull_script anonymous
write_pull_image_script $image_list $pull_script
check_return_code $?

write_tag_image_script $image_list $tag_script
check_return_code $?

write_push_image_script $image_list $push_script
check_return_code $?

#
# instana operator
#
print_mirror_header "instana-operator"

./generate-instana-operator-image-list.sh
check_return_code $?

image_list=${MIRROR_HOME}/${INSTANA_OPERATOR_IMAGE_LIST_FILE}
pull_script=${MIRROR_HOME}/$PULL_INSTANA_OPERATOR_IMAGES_SCRIPT
push_script=${MIRROR_HOME}/$PUSH_INSTANA_OPERATOR_IMAGES_SCRIPT
tag_script=${MIRROR_HOME}/$TAG_INSTANA_OPERATOR_IMAGES_SCRIPT

write_pull_image_script $image_list $pull_script
check_return_code $?

write_tag_image_script $image_list $tag_script
check_return_code $?

write_push_image_script $image_list $push_script
check_return_code $?

#
# run generated scripts
#
if test $run = "run"; then
   echo running mirror images scripts...

   ./mirror-images.sh
   check_return_code $?
fi

