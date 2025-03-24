#!/bin/bash

source ../instana.env
source ./help-functions.sh

bin_home=$(get_bin_home)
export PATH=".:$bin_home:$PATH"

set -x

echo "Deleteing cluster postgres..."

$KUBECTL -n instana-postgres delete cluster postgres --wait=false
$KUBECTL -n instana-postgres wait --for=delete pod -l"cnpg.io/cluster"=postgres --timeout=${WAIT_TIMEOUT:-"600s"}

echo
echo "Deleting postgres-operator..."

helm uninstall postgres-operator -n instana-postgres
$KUBECTL -n instana-operator wait --for=delete pod -l"app.kubernetes.io/name"="cloudnative-pg" --timeout=${WAIT_TIMEOUT:-"600s"}

#These resources were kept due to the resource policy:
#[CustomResourceDefinition] backups.postgresql.cnpg.io
#[CustomResourceDefinition] clusters.postgresql.cnpg.io
#[CustomResourceDefinition] poolers.postgresql.cnpg.io
#[CustomResourceDefinition] scheduledbackups.postgresql.cnpg.io

