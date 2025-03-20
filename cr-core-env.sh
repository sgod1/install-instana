#!/bin/bash

source ../instana.env
source ./help-functions.sh
source ./cr-env.sh
source ./release.env

function update_clickhouse_hosts() {
   local coreyaml=$1
   local profile=${2:-"profile value expected"}

   # select from clickhouse yaml
   #.spec.configuration.clusters.[] | select(.name == "local") |
   #.layout.shardsCount

   # or select from clickhouse-env.yaml
   clickhouse_env_yaml="clickhouse-env.yaml"
   local sval=`gen/bin/yq ".env.[]|select(.name==\"shards-count\")|.values.$profile" $clickhouse_env_yaml`

   if test $sval = "null"; then
      sval=`gen/bin/yq ".env.[]|select(.name==\"shards-count\")|.values.default" $clickhouse_env_yaml`

      if test $sval = "null"; then
         echo ... error ... $clickhouse_env_yaml: shards-count value udefined for $profile or default profiles.
         exit 1
      fi
   fi

   # number of replicas is fixed
   rmax=2 

   local replicas=()
   for ((ri = 0; ri < $rmax; ri++)); do
      replicas+=($ri)
   done

   # number of shards is configured in clickhouse-env.yaml
   smax=$sval

   local shards=()
   for ((si = 0; si < $smax; si++)); do
      shards+=($si)
   done

   local hosts=()

   for s in ${shards[@]}; do
      for r in ${replicas[@]}; do
         hosts+=("chi-instana-local-$s-$r.instana-clickhouse.svc")
      done
   done

   hlist=""
   for h in ${hosts[@]}; do
      echo $h
      if test -z "$hlist"; then
         hlist=\"$h\"
      else
         hlist="$hlist, \"$h\""
      fi
   done

   hlist="[${hlist}]"

   #echo $hlist

   gen/bin/yq -i "(.spec.datastoreConfigs.clickhouseConfigs.[]|select(.clusterName=\"local\")|.hosts)=$hlist" $coreyaml
}

#
# main
#

replace_manifest=${1:-"noreplace"}

export instana_base_domain=${INSTANA_BASE_DOMAIN}
export private_registry=${PRIVATE_REGISTRY}
export core_image_tag=${__instana_sem_version["${INSTANA_VERSION}"]}

export rwo_storageclass=${RWO_STORAGECLASS}
export rwx_storageclass=${RWX_STORAGECLASS}

template_cr="core-template.yaml"
env_file="core-env.yaml"
profile=${INSTANA_INSTALL_PROFILE:-"template"}

OUT_DIR=$(get_make_manifest_home)
#MANIFEST="${OUT_DIR}/core-env-${INSTANA_VERSION}.yaml"

MANIFEST=$(format_file_path $OUT_DIR "core.yaml" $profile $INSTANA_VERSION)

check_replace_manifest $MANIFEST $replace_manifest
copy_template_manifest $template_cr $MANIFEST $profile

cr_env $template_cr $env_file $MANIFEST $profile

# postprocess manifest with dynamic clickhouse host list
update_clickhouse_hosts $MANIFEST $profile

echo updated core manifest $MANIFEST, profile $profile
