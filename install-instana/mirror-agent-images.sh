#!/bin/bash

source ../instana.env
source ./install.env
source ./help-functions.sh

# select from release.yaml
AGENT_IMG="instana/agent"
AGENT_IMG_TAG="latest"

K8S_CENSOR_IMG="instana/k8sensor"
K8S_CENSOR_IMG_TAG="latest"

AGENT_OPERATOR_IMG="instana/instana-agent-operator"
AGENT_OPERATOR_TAG="latest"

__agent_image_list=("${AGENT_IMG}:${AGENT_IMG_TAG}" "${K8S_CENSOR_IMG}:${K8S_CENSOR_IMG_TAG}" "${AGENT_OPERATOR_IMG}:${AGENT_OPERATOR_TAG}")

STATIC_AGENT_IMG="instana/release/agent/static"

__static_agent_image_list=("${STATIC_AGENT_IMG}")

ICR_IO="icr.io"
CONTAINERS_INSTANA_IO="containers.instana.io"

#
# main
#

MIRROR_HOME=$(get_make_mirror_home)
MIRROR_HOME=${MIRROR_HOME}/agent
mkdir -p ${MIRROR_HOME}

ICR_IO_OUTFILE="${MIRROR_HOME}/${ICR_IO}-${AGENT_IMAGE_LIST_FILE}"
CONTAINERS_INSTANA_IO_OUTFILE="${MIRROR_HOME}/${CONTAINERS_INSTANA_IO}-${AGENT_IMAGE_LIST_FILE}"

IMG_PLATFORM="--platform $(podman_image_platform $PODMAN_IMG_PLATFORM)"

# dynamic image list
ts=`date`

echo ""
echo writing dynamic agent image list to ${ICR_IO_OUTFILE}

echo "# Agent images, $ts" > ${ICR_IO_OUTFILE}

for img in ${__agent_image_list[@]}
do
   echo "${ICR_IO}/${img}" >> ${ICR_IO_OUTFILE}
done

# static agent image list

echo ""
echo writing static agent image list to ${CONTAINERS_INSTANA_IO_OUTFILE}


echo "# Static agent images, $ts" > ${CONTAINERS_INSTANA_IO_OUTFILE}

for img in ${__static_agent_image_list[@]}
do
   echo "${CONTAINERS_INSTANA_IO}/${img}" >> ${CONTAINERS_INSTANA_IO_OUTFILE}
done

#
# pull agent images
#

echo ""
echo "-- pull agent images..."
echo ""

for img in ${__agent_image_list[@]}
do
   $PODMAN pull ${IMG_PLATFORM} ${ICR_IO}/${img}
   rc=$?

   if (( $rc > 0 )); then echo error: image pull ${IMG_PLATFORM} ${ICR_IO}/${img} failed, rc=$rc; exit $rc; fi
done

#
# pull static agent images
#

echo ""
echo "-- pull static agent images..."
echo ""

$PODMAN login $PODMAN_TLS_VERIFY --username _ --password $DOWNLOAD_KEY $CONTAINERS_INSTANA_IO
rc=$?
if (( $rc > 0 )); then echo error: Login to container registry $CONTAINERS_INSTANA_IO failed, rc=$rc; exit $rc; fi

for img in ${__static_agent_image_list[@]}
do
   $PODMAN pull ${IMG_PLATFORM} ${CONTAINERS_INSTANA_IO}/${img}
   rc=$?

   if (( $rc > 0 )); then echo error: image pull ${IMG_PLATFORM} ${CONTAINERS_INSTANA_IO}/${img} failed, rc=$rc; exit $rc; fi
done

#
# tag agent images
#

echo ""
echo "-- tag agent images..."
echo ""

for img in ${__agent_image_list[@]}
do
   echo "$PODMAN tag ${ICR_IO}/${img} ${PRIVATE_REGISTRY}/${img}"
   $PODMAN tag ${ICR_IO}/${img} ${PRIVATE_REGISTRY}/${img}
   rc=$?

   if (( $rc > 0 )); then echo error: image tag ${ICR_IO}/${img} ${PRIVATE_REGISTRY}/${img} failed, rc=$rc; exit $rc; fi
done

echo ""

echo ""
echo "-- tag static agent images..."
echo ""

for img in ${__static_agent_image_list[@]}
do
   echo "$PODMAN tag ${CONTAINERS_INSTANA_IO}/${img} ${PRIVATE_REGISTRY}/${img}"
   $PODMAN tag ${CONTAINERS_INSTANA_IO}/${img} ${PRIVATE_REGISTRY}/${img}
   rc=$?

   if (( $rc > 0 )); then echo error: image tag ${ICR_IO}/${img} ${PRIVATE_REGISTRY}/${img} failed, rc=$rc; exit $rc; fi
done

echo ""

#
# push agent images
#

echo ""
echo "-- push agent images..."
echo ""

$PODMAN login $PODMAN_TLS_VERIFY --username $PRIVATE_REGISTRY_USER --password $PRIVATE_REGISTRY_PASSWORD $PRIVATE_DOCKER_SERVER
rc=$?
if (( $rc > 0 )); then echo error: Login to private registry $PRIVATE_REGISTRY failed, rc=$rc; exit $rc; fi

for img in ${__agent_image_list[@]}
do
   $PODMAN push ${PRIVATE_REGISTRY}/${img}
   rc=$?

   if (( $rc > 0 )); then echo error: image tag ${ICR_IO}/${img} ${PRIVATE_REGISTRY}/${img} failed, rc=$rc; exit $rc; fi
done

for img in ${__static_agent_image_list[@]}
do
   $PODMAN push ${PRIVATE_REGISTRY}/${img}
   rc=$?

   if (( $rc > 0 )); then echo error: image tag ${ICR_IO}/${img} ${PRIVATE_REGISTRY}/${img} failed, rc=$rc; exit $rc; fi
done

echo ""
cat $ICR_IO_OUTFILE
echo ""
cat $CONTAINERS_INSTANA_IO_OUTFILE
