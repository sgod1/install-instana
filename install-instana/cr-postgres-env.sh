#!/bin/bash

source ../instana.env
source ./install.env
source ./datastore-images.env
source ./help-functions.sh
source ./cr-env.sh

export PATH=".:$PATH"

replace_manifest=${1:-"noreplace"}

export postgres_image=${PRIVATE_REGISTRY}/${POSTGRES_IMG}
export rwo_storageclass=${RWO_STORAGECLASS}

template_cr=$CR_TEMPLATE_FILENAME_POSTGRES
env_file=$CR_ENV_FILENAME_POSTGRES
profile=${INSTANA_INSTALL_PROFILE}

OUT_DIR=$(get_make_manifest_home)

MANIFEST=$(format_file_path $OUT_DIR $MANIFEST_FILENAME_POSTGRES $profile $INSTANA_VERSION)

check_replace_manifest $MANIFEST $replace_manifest
copy_template_manifest $template_cr $MANIFEST $profile

# tolerations
tolpaths=".spec.affinity.tolerations"

export postgres_toleration_key=${POSTGRES_TOLERATION_KEY:-${TOLERATION_KEY:-"nokey"}}
export postgres_toleration_value=${POSTGRES_TOLERATION_VALUE:-${TOLERATION_VALUE:-"novalue"}}

cr-tolerations.sh $MANIFEST $postgres_toleration_key $postgres_toleration_value $tolpaths
check_return_code $?

# env
cr_env $template_cr $env_file $MANIFEST $profile
check_return_code $?

echo updated postgres manifest $MANIFEST, profile $profile
