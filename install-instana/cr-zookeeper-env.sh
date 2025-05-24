#!/bin/bash

source ../instana.env
source ./install.env
source ./datastore-images.env
source ./help-functions.sh
source ./cr-env.sh

export PATH=".:$PATH"

replace_manifest=${1:-"noreplace"}

export zookeeper_image_name=`echo ${ZOOKEEPER_IMG} | cut -d : -f 1 -`
export zookeeper_image_repository=${PRIVATE_REGISTRY}/${zookeeper_image_name}
export zookeeper_image_tag=`echo ${ZOOKEEPER_IMG} | cut -d : -f 2 -`

export rwo_storageclass=${RWO_STORAGECLASS}

template_cr=$CR_TEMPLATE_FILENAME_ZOOKEEPER
env_file=$CR_ENV_FILENAME_ZOOKEEPER
profile=${INSTANA_INSTALL_PROFILE}

OUT_DIR=$(get_make_manifest_home)

MANIFEST=$(format_file_path $OUT_DIR $MANIFEST_FILENAME_ZOOKEEPER $profile $INSTANA_VERSION)

check_replace_manifest $MANIFEST $replace_manifest
copy_template_manifest $template_cr $MANIFEST $profile

# tolerations
tolpaths=".spec.pod.tolerations"

export zookeeper_toleration_key=${ZOOKEEPER_TOLERATION_KEY:-${TOLERATION_KEY:-"nokey"}}
export zookeeper_toleration_value=${ZOOKEEPER_TOLERATION_VALUE:-${TOLERATION_VALUE:-"novalue"}}

cr-tolerations.sh $MANIFEST $zookeeper_toleration_key $zookeeper_toleration_value $tolpaths
check_return_code $?

# env
cr_env $template_cr $env_file $MANIFEST $profile
check_return_code $?

# post gen update, delete pod security context for ocp
# yq -i 'del(.spec.pod.securityContext)' $MANIFEST
if [[ $PLATFORM == "ocp" ]]; then
  echo "ocp ... deleting .spec.pod.securityContext from $MANIFEST"
  $(get_bin_home)/yq -i 'del(.spec.pod.securityContext)' $MANIFEST
fi

echo updated zookeeper manifest $MANIFEST, profile $profile
