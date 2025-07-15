#!/bin/bash

source ../instana.env

source ./release.env

source ./install.env

source ./datastore-images.env

source ./help-functions.sh

MIRROR_HOME=$(get_mirror_home)

MIRROR_HOME=${MIRROR_HOME}/${INSTANA_VERSION}
mkdir -p $MIRROR_HOME

ARTIFACT_PUBLIC="artifact-public.instana.io"

OUTFILE="${MIRROR_HOME}/${INSTANA_DATASTORE_IMAGE_LIST_FILE}"

# instana semantic version
semver=${__instana_sem_version[${INSTANA_VERSION}]}

echo writing datastore image list to ${OUTFILE}, Instana version: ${semver}

echo "# Datastore images, Instana version: $INSTANA_VERSION" > ${OUTFILE}

echo "# cassandra" >> ${OUTFILE}
for img in ${__datastore_image_list_cassandra[@]}
do
   echo "${ARTIFACT_PUBLIC}/${img}" >> ${OUTFILE}
done

echo "# clickhouse" >> ${OUTFILE}
for img in ${__datastore_image_list_clickhouse[@]}
do
   echo "${ARTIFACT_PUBLIC}/${img}" >> ${OUTFILE}
done

echo "# elasticsearch" >> ${OUTFILE}
for img in ${__datastore_image_list_elasticsearch[@]}
do
   echo "${ARTIFACT_PUBLIC}/${img}" >> ${OUTFILE}
done

echo "# kafka" >> ${OUTFILE}
for img in ${__datastore_image_list_kafka[@]}
do
   echo "${ARTIFACT_PUBLIC}/${img}" >> ${OUTFILE}
done

echo "# postgresql" >> ${OUTFILE}
for img in ${__datastore_image_list_postgresql[@]}
do
   echo "${ARTIFACT_PUBLIC}/${img}" >> ${OUTFILE}
done

echo "# zookeeper" >> ${OUTFILE}
for img in ${__datastore_image_list_zookeeper[@]}
do
   echo "${ARTIFACT_PUBLIC}/${img}" >> ${OUTFILE}
done

echo "# beeinstana" >> ${OUTFILE}
for img in ${__datastore_image_list_beeinstana[@]}
do
   echo "${ARTIFACT_PUBLIC}/${img}" >> ${OUTFILE}
done
