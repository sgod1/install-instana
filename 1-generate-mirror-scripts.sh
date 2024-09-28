#!/bin/bash

source ../instana.env
source ./help-functions.sh

function write_pull_image_script() {
   image_list_file=$1
   script_file=$2
   anonymous=$3

   echo writing pull image script to $script_file

   /usr/bin/awk -v ANONYMOUS=$anonymous '
   BEGIN { 
      print "#!/bin/bash" 
      print "source ../../../instana.env"
      if (ANONYMOUS=="") print "$PODMAN login --username _ --password $DOWNLOAD_KEY $INSTANA_REGISTRY";
      print "set -x"
   }
   NF > 0 && $0 !~ /^#/ { print "$PODMAN pull", $0 } ' $image_list_file > $script_file

   chmod +x $script_file
}

function write_tag_image_script() {
   image_list_file=$1
   script_file=$2

   echo writing tag image script to $script_file

   /usr/bin/awk -v INSTANA_REGISTRY=$INSTANA_REGISTRY -v QUAY_REGISTRY=$QUAY_REGISTRY '
   BEGIN {
      print "#!/bin/bash" 
      print "source ../../../instana.env"
      print "set -x"
   }
   NF > 0 && $0 !~ /^#/ && $0 ~ /artifact-public.instana.io/ { sub("--platform linux/amd64", ""); printf("$PODMAN tag %s", $0); sub(INSTANA_REGISTRY, "$PRIVATE_REGISTRY"); printf(" %s\n", $0) }
   NF > 0 && $0 !~ /^#/ && $0 ~ /^quay.io/ { printf("$PODMAN tag %s", $0); sub(QUAY_REGISTRY, "$PRIVATE_REGISTRY"); printf(" %s\n", $0) } 
   NF > 0 && $0 !~ /^#/ && $0 ~ /^cr.dtsx.io/ { printf("$PODMAN tag %s", $0); sub("cr.dtsx.io", "$PRIVATE_REGISTRY"); printf(" %s\n", $0) } 
   ' $image_list_file > $script_file

   chmod +x $script_file
}

function write_push_image_script() {
   image_list_file=$1
   script_file=$2

   echo writing push image script to $script_file

   /usr/bin/awk -v INSTANA_REGISTRY=$INSTANA_REGISTRY -v QUAY_REGISTRY=$QUAY_REGISTRY '
   BEGIN { 
      print "#!/bin/bash" 
      print "source ../../../instana.env"
      print "$PODMAN login --tls-verify=$PODMAN_TLS_VERIFY --username $PRIVATE_REGISTRY_USER --password $PRIVATE_REGISTRY_PASSWORD $PRIVATE_DOCKER_REGISTRY"
      print "set -x"
   }
   NF > 0 && $0 !~ /^#/ && $0 ~ /artifact-public.instana.io/ { sub("--platform linux/amd64", ""); sub(INSTANA_REGISTRY, "$PRIVATE_REGISTRY"); printf("$PODMAN push --tls-verify=$PODMAN_TLS_VERIFY %s\n", $0) }
   NF > 0 && $0 !~ /^#/ && $0 ~ /^quay.io/ { sub(QUAY_REGISTRY, "$PRIVATE_REGISTRY"); printf("$PODMAN push --tls-verify=$PODMAN_TLS_VERIFY %s\n", $0) }
   NF > 0 && $0 !~ /^#/ && $0 ~ /^cr.dtsx.io/ { sub("cr.dtsx.io", "$PRIVATE_REGISTRY"); printf("$PODMAN push --tls-verify=$PODMAN_TLS_VERIFY %s\n", $0) }
   ' $image_list_file > $script_file

   chmod +x $script_file
}

MIRROR_HOME=$(get_make_mirror_home)

#
# instana backend
#

IMAGE_LIST=${MIRROR_HOME}/${INSTANA_BACKEND_IMAGE_LIST_FILE}

PULL_SCRIPT=${MIRROR_HOME}/$PULL_BACKEND_IMAGES_SCRIPT
PUSH_SCRIPT=${MIRROR_HOME}/$PUSH_BACKEND_IMAGES_SCRIPT
TAG_SCRIPT=${MIRROR_HOME}/$TAG_BACKEND_IMAGES_SCRIPT

echo ""
echo writing backend mirror scripts...
echo ""

./generate-backend-image-list.sh

write_pull_image_script $IMAGE_LIST $PULL_SCRIPT
write_tag_image_script $IMAGE_LIST $TAG_SCRIPT
write_push_image_script $IMAGE_LIST $PUSH_SCRIPT

#
# datastores
#

IMAGE_LIST=${MIRROR_HOME}/${INSTANA_DATASTORE_IMAGE_LIST_FILE}

PULL_SCRIPT=${MIRROR_HOME}/$PULL_DATASTORE_IMAGES_SCRIPT
PUSH_SCRIPT=${MIRROR_HOME}/$PUSH_DATASTORE_IMAGES_SCRIPT
TAG_SCRIPT=${MIRROR_HOME}/$TAG_DATASTORE_IMAGES_SCRIPT

echo ""
echo writing datastore mirror scripts...
echo ""

./generate-datastore-image-list.sh

write_pull_image_script $IMAGE_LIST $PULL_SCRIPT
write_tag_image_script $IMAGE_LIST $TAG_SCRIPT
write_push_image_script $IMAGE_LIST $PUSH_SCRIPT

#
# cert manager
#

IMAGE_LIST=${MIRROR_HOME}/${CERT_MGR_IMAGE_LIST_FILE}

PULL_SCRIPT=${MIRROR_HOME}/$PULL_CERT_MGR_IMAGES_SCRIPT
PUSH_SCRIPT=${MIRROR_HOME}/$PUSH_CERT_MGR_IMAGES_SCRIPT
TAG_SCRIPT=${MIRROR_HOME}/$TAG_CERT_MGR_IMAGES_SCRIPT

echo ""
echo writing cert-manager mirror scripts...
echo ""

./generate-certmgr-image-list.sh

#write_pull_image_script $IMAGE_LIST $PULL_SCRIPT anonymous
write_pull_image_script $IMAGE_LIST $PULL_SCRIPT
write_tag_image_script $IMAGE_LIST $TAG_SCRIPT
write_push_image_script $IMAGE_LIST $PUSH_SCRIPT
