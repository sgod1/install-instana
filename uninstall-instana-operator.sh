#!/bin/bash

source ../instana.env

namespace=${1:-"instana-operator"}

echo deleting deployments/instana-operator, namespace instana-operator
$KUBECTL delete -n $namespace deployments/instana-operator

echo deleting deployments/instana-operator-webhook, namespace instana-operator
$KUBECTL delete -n $namespace deployments/instana-operator-webhook

echo deleting serviceaccounts/instana-operator, namespace instana-operator
$KUBECTL delete -n $namespace serviceaccounts/instana-operator

echo deleting serviceaccounts/instana-operator-webhook, namespace instana-operator
$KUBECTL delete -n $namespace serviceaccounts/instana-operator-webhook

echo deleting customresourcedefinitions/cores.instana.io
$KUBECTL delete customresourcedefinitions/cores.instana.io 

echo deleting customresourcedefinitions/units.instana.io
$KUBECTL delete customresourcedefinitions/units.instana.io

echo deleting clusterroles/instana-operator
$KUBECTL delete clusterroles/instana-operator

echo deleting clusterroles/instana-operator-webhook
$KUBECTL delete clusterroles/instana-operator-webhook

echo deleting clusterrolebindings/instana-operator
$KUBECTL delete clusterrolebindings/instana-operator

echo deleting clusterrolebindings/instana-operator-webhook
$KUBECTL delete clusterrolebindings/instana-operator-webhook

echo deleting roles/instana-operator-leader-election, namespace instana-operator
$KUBECTL delete -n $namespace roles/instana-operator-leader-election

echo deleting rolebindings/instana-operator-leader-election, namespace instana-operator
$KUBECTL delete -n $namespace rolebindings/instana-operator-leader-election

echo deleting services/instana-operator-webhook, namespace instana-operator
$KUBECTL delete -n $namespace services/instana-operator-webhook

echo deleting certificates/instana-operator-webhook, namespace instana-operator
$KUBECTL delete -n $namespace certificates/instana-operator-webhook

echo deleting issuers/instana-operator-webhook, namespace instana-operator
$KUBECTL delete -n $namespace issuers/instana-operator-webhook

echo deleting validatingwebhookconfigurations/instana-operator-webhook-validating
$KUBECTL delete validatingwebhookconfigurations/instana-operator-webhook-validating
