#!/bin/bash

# apply, template
action=${1:-"apply"}

source ../instana.env
source ./help-functions.sh

INSTALL_HOME=$(get_install_home)
BIN_HOME=$(get_bin_home)

INSTANA_KUBECTL=$BIN_HOME/kubectl-instana

VALUES_FILE="$INSTALL_HOME/instana-operator-values.yaml"

MANIFEST_DIR=$INSTALL_HOME/instana-operator-manifests

MANIFEST_DIR=$MANIFEST_DIR/"${INSTANA_PLUGIN_VERSION}-${INSTANA_VERSION}"
mkdir -p $MANIFEST_DIR

cat << EOF > $VALUES_FILE
image:
  registry: $PRIVATE_REGISTRY

imagePullSecrets:
- name: instana-registry
EOF

# install instana operator

if test "$action" = "apply"
then
echo Installing instana operator, action apply, values file $VALUES_FILE

$INSTANA_KUBECTL operator apply --values $VALUES_FILE --namespace=instana-operator

# Installing instana operator, values file gen/instana-operator-values.yaml
# namespaces/instana-operator updated
# serviceaccounts/instana-operator created
# serviceaccounts/instana-operator-webhook created
# customresourcedefinitions/cores.instana.io created
# customresourcedefinitions/units.instana.io created
# clusterroles/instana-operator created
# clusterroles/instana-operator-webhook created
# clusterrolebindings/instana-operator created
# clusterrolebindings/instana-operator-webhook created
# roles/instana-operator-leader-election created
# rolebindings/instana-operator-leader-election created
# services/instana-operator-webhook created
# deployments/instana-operator created
# deployments/instana-operator-webhook created
# certificates/instana-operator-webhook created
# issuers/instana-operator-webhook created
# validatingwebhookconfigurations/instana-operator-webhook-validating created

elif test "$action" = "template"
then
echo Installing instana operator, action template, values file $VALUES_FILE, output-dir $MANIFEST_DIR

$INSTANA_KUBECTL operator template --values $VALUES_FILE --namespace=instana-operator --output-dir=$MANIFEST_DIR

else
echo Invalid instsana operator action $action, expected actions: apply, template
exit 1

fi
