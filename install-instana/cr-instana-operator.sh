#!/bin/bash

source ../instana.env
source ./help-functions.sh

export PATH=".:$PATH"

INSTALL_HOME=$(get_install_home)
BIN_HOME=$(get_bin_home)

INSTANA_KUBECTL=$BIN_HOME/kubectl-instana

MANIFEST_DIR=$INSTALL_HOME/instana-operator-manifests

MANIFEST_DIR=$MANIFEST_DIR/"${INSTANA_PLUGIN_VERSION}-${INSTANA_VERSION}"

replace=${1:-"no-replace"}

check_replace_manifest_dir $MANIFEST_DIR $replace

if test -d $MANIFEST_DIR; then
   rm -r $MANIFEST_DIR
fi

mkdir -p $MANIFEST_DIR

VALUES_FILE="$INSTALL_HOME/instana-operator-values-${INSTANA_VERSION}.yaml"

echo Generating Instana operator values file $VALUES_FILE
echo ""

cat << EOF > $VALUES_FILE
image:
  registry: $PRIVATE_REGISTRY

imagePullSecrets:
- name: instana-registry
EOF

echo Generating Instana operator manifests in $MANIFEST_DIR directory
echo ""

#set -x
$INSTANA_KUBECTL operator template --namespace instana-operator --values $VALUES_FILE --output-dir $MANIFEST_DIR

# tolerations operator
MANIFEST=${MANIFEST_DIR}/deployment_instana-operator_instana-operator.yaml

tolpaths=".spec.template.spec.tolerations"

instana_toleration_key=${INSTANA_TOLERATION_KEY:-${TOLERATION_KEY:-"nokey"}}
instana_toleration_value=${INSTANA_TOLERATION_VALUE:-${TOLERATION_VALUE:-"novalue"}}

cr-tolerations.sh $MANIFEST $instana_toleration_key $instana_toleration_value $tolpaths
check_return_code $?

# tolerations operator webhook
MANIFEST=${MANIFEST_DIR}/deployment_instana-operator_instana-operator-webhook.yaml

cr-tolerations.sh $MANIFEST $instana_toleration_key $instana_toleration_value $tolpaths
check_return_code $?
