#!/bin/bash

source ../instana.env

source ./install.env

source ./datastore-images.env

source ./help-functions.sh

MIRROR_HOME=$(get_mirror_home)

MIRROR_HOME=${MIRROR_HOME}/${INSTANA_VERSION}
mkdir -p $MIRROR_HOME

ARTIFACT_PUBLIC="artifact-public.instana.io"

OUTFILE="${MIRROR_HOME}/${INSTANA_DATASTORE_IMAGE_LIST_FILE}"

IMG_PLATFORM=${PODMAN_IMG_PLATFORM:-"--platform linux/amd64"}

echo writing datastore image list to ${OUTFILE}, Instana version: ${INSTANA_VERSION}

echo "# Datastore images, Instana version: $INSTANA_VERSION" > ${OUTFILE}

echo "# cassandra" >> ${OUTFILE}
for img in ${__datastore_image_list_cassandra[@]}
do
   echo "${IMG_PLATFORM} ${ARTIFACT_PUBLIC}/${img}" >> ${OUTFILE}
done

echo "# clickhouse" >> ${OUTFILE}
for img in ${__datastore_image_list_clickhouse[@]}
do
   echo "${IMG_PLATFORM} ${ARTIFACT_PUBLIC}/${img}" >> ${OUTFILE}
done

echo "# elasticsearch" >> ${OUTFILE}
for img in ${__datastore_image_list_elasticsearch[@]}
do
   echo "${IMG_PLATFORM} ${ARTIFACT_PUBLIC}/${img}" >> ${OUTFILE}
done

echo "# kafka" >> ${OUTFILE}
for img in ${__datastore_image_list_kafka[@]}
do
   echo "${IMG_PLATFORM} ${ARTIFACT_PUBLIC}/${img}" >> ${OUTFILE}
done

echo "# postgresql" >> ${OUTFILE}
for img in ${__datastore_image_list_postgresql[@]}
do
   echo "${IMG_PLATFORM} ${ARTIFACT_PUBLIC}/${img}" >> ${OUTFILE}
done

echo "# zookeeper" >> ${OUTFILE}
for img in ${__datastore_image_list_zookeeper[@]}
do
   echo "${IMG_PLATFORM} ${ARTIFACT_PUBLIC}/${img}" >> ${OUTFILE}
done

echo "# beeinstana" >> ${OUTFILE}
for img in ${__datastore_image_list_beeinstana[@]}
do
   echo "${IMG_PLATFORM} ${ARTIFACT_PUBLIC}/${img}" >> ${OUTFILE}
done
