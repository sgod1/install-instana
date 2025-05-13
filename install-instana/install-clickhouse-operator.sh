#!/bin/bash

# install, upgrade
helm_action=${1:-"install"}

source ../instana.env
source ./help-functions.sh
source ./datastore-images.env

CHART_HOME=$(get_chart_home)
CHART_HOME=${CHART_HOME}/${INSTANA_VERSION}
mkdir -p ${CHART_HOME}

if is_platform_ocp "$PLATFORM"; then
   SCC_HOME=$(get_manifest_home)
   SCC=$(format_file_path $SCC_HOME $MANIFEST_FILENAME_CLICKHOUSE_SCC $INSTANA_INSTALL_PROFILE $INSTANA_VERSION)

   # apply scc
   echo applying clickhouse scc $SCC

   if [[ ! -f $SCC ]]; then
      echo clickhouse scc $SCC not found
      exit 1
   fi

   #$KUBECTL -n instana-clickhouse adm policy add-scc-to-user privileged -z clickhouse-operator
   #$KUBECTL -n instana-clickhouse adm policy add-scc-to-user privileged -z clickhouse-operator-ibm-clickhouse-operator
   #$KUBECTL -n instana-clickhouse adm policy add-scc-to-user privileged -z default

   $KUBECTL apply -f $SCC -n instana-clickhouse
   check_return_code $?
fi

# install clickhouse operator chart
CHART=$CHART_HOME/ibm-clickhouse-operator-${CLICKHOUSE_OPERATOR_CHART_VERSION}.tgz

echo installing clickhouse operator helm chart $CHART

if test ! -f $CHART; then
   echo helm chart $CHART not found
   exit 1
fi

clickhouse_operator_image_tag=`echo $CLICKHOUSE_OPERATOR_IMG | cut -d : -f 2 -`

values_yaml="$(get_install_home)/clickhouse-operator-values-${INSTANA_VERSION}.yaml"

cat <<EOF > $values_yaml
operator:
   image:
      repository: $PRIVATE_REGISTRY/clickhouse-operator
      tag: $clickhouse_operator_image_tag

imagePullSecrets:
   - name: "instana-registry"

tolerations:
  - effect: NoSchedule
    key: dedicated
    operator: Equal
    value: appng
EOF

helm ${helm_action} clickhouse-operator -n instana-clickhouse $CHART -f $values_yaml \
   --wait --timeout 60m0s
rc=$?

check_return_code $rc

# todo check cr status

exit $rc
