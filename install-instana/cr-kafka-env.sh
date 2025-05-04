#!/bin/bash

source ../instana.env
source ./install.env
source ./datastore-images.env
source ./help-functions.sh
source ./cr-env.sh

replace_manifest=${1:-"noreplace"}

export kafka_operator_image=${PRIVATE_REGISTRY}/${KAFKA_OPERATOR_IMG}
export kafka_image=${PRIVATE_REGISTRY}/${KAFKA_IMG}

export rwo_storage_class=$RWO_STORAGECLASS

template_cr=$CR_TEMPLATE_FILENAME_KAFKA
env_file=$CR_ENV_FILENAME_KAFKA
profile=${INSTANA_INSTALL_PROFILE}

OUT_DIR=$(get_make_manifest_home)

MANIFEST=$(format_file_path $OUT_DIR $MANIFEST_FILENAME_KAFKA $profile $INSTANA_VERSION)

check_replace_manifest $MANIFEST $replace_manifest
copy_template_manifest $template_cr $MANIFEST $profile

cr_env $template_cr $env_file $MANIFEST $profile
check_return_code $?

# platform-specific
# delete pod security context if openshift
if [[ $PLATFORM == "ocp" ]]; then
  echo "ocp ... deleting .spec.entityOperator.template.pod.securityContext from $MANIFEST"
  $(get_bin_home)/yq -i 'del(.spec.entityOperator.template.pod.securityContext)' $MANIFEST
fi

#
# write kafka user
#
cat <<EOF >> $MANIFEST
---
apiVersion: kafka.strimzi.io/v1beta2
kind: KafkaUser
metadata:
  name: strimzi-kafka-user
  labels:
    strimzi.io/cluster: instana
spec:
  authentication:
    type: scram-sha-512
  authorization:
    type: simple
    acls:
      - resource:
          type: topic
          name: '*'
          patternType: literal
        operation: All
        host: "*"
      - resource:
          type: group
          name: '*'
          patternType: literal
        operation: All
        host: "*"
EOF

echo updated kafka manifest $MANIFEST, profile $profile
