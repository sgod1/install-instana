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
AGENT_OPERATOR_TAG="2.1.22"

__agent_image_list=("${AGENT_IMG}:${AGENT_IMG_TAG}" "${K8S_CENSOR_IMG}:${K8S_CENSOR_IMG_TAG}" "${AGENT_OPERATOR_IMG}:${AGENT_OPERATOR_TAG}")

ICR_IO="icr.io"

MIRROR_HOME=$(get_make_mirror_home)
MIRROR_HOME=${MIRROR_HOME}/${INSTANA_VERSION}
mkdir -p ${MIRROR_HOME}

OUTFILE="${MIRROR_HOME}/${AGENT_IMAGE_LIST_FILE}"

IMG_PLATFORM="--platform $(podman_image_platform $PODMAN_IMG_PLATFORM)"

echo writing agent image list to ${OUTFILE}

echo "# Agent images, Instana version: $INSTANA_VERSION" > ${OUTFILE}

for img in ${__agent_image_list[@]}
do
   echo "${IMG_PLATFORM} ${ICR_IO}/${img}" >> ${OUTFILE}
done

#
# pull agent images
#

echo "-- pull agent images..."
echo ""

for img in ${__agent_image_list[@]}
do
   $PODMAN pull ${IMG_PLATFORM} ${ICR_IO}/${img}
   rc=$?

   if [[ $rc > 0 ]]; then echo error: image pull ${IMG_PLATFORM} ${ICR_IO}/${img} failed, rc=$rc; exit $rc; fi
done

#
# tag agent images
#

echo "-- tag agent images..."
echo ""

for img in ${__agent_image_list[@]}
do
   echo "$PODMAN tag ${ICR_IO}/${img} ${PRIVATE_REGISTRY}/${img}"
   $PODMAN tag ${ICR_IO}/${img} ${PRIVATE_REGISTRY}/${img}
   rc=$?

   if [[ $rc > 0 ]]; then echo error: image tag ${ICR_IO}/${img} ${PRIVATE_REGISTRY}/${img} failed, rc=$rc; exit $rc; fi
done

echo ""

#
# push agent images
#

echo "-- push agent images..."
echo ""

$PODMAN login $PODMAN_TLS_VERIFY --username $PRIVATE_REGISTRY_USER --password $PRIVATE_REGISTRY_PASSWORD $PRIVATE_DOCKER_SERVER
rc=$?
if [[ $rc > 0 ]]; then echo error: Login to private registry $PRIVATE_REGISTRY failed, rc=$rc; exit $rc; fi

for img in ${__agent_image_list[@]}
do
   $PODMAN push ${PRIVATE_REGISTRY}/${img}
   rc=$?

   if [[ $rc > 0 ]]; then echo error: image tag ${ICR_IO}/${img} ${PRIVATE_REGISTRY}/${img} failed, rc=$rc; exit $rc; fi
done

cat $OUTFILE
