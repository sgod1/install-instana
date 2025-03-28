#!/bin/bash

source ../instana.env
source ./install.env
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

   # number of replicas is 2 (fixed) 
   local replicas=(0 1)

   #rmax=2 
   #
   #local replicas=()
   #for ((ri = 0; ri < $rmax; ri++)); do
   #   replicas+=($ri)
   #done

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
export resource_profile=$CORE_RESOURCE_PROFILE
export agent_acceptor_host=$INSTANA_AGENT_ACCEPTOR

export rwo_storageclass=${RWO_STORAGECLASS}
export rwx_storageclass=${RWX_STORAGECLASS}

template_cr=$CR_TEMPLATE_FILENAME_CORE
env_file=$CR_ENV_FILENAME_CORE
profile=${INSTANA_INSTALL_PROFILE}

OUT_DIR=$(get_make_manifest_home)

MANIFEST=$(format_file_path $OUT_DIR $MANIFEST_FILENAME_CORE $profile $INSTANA_VERSION)

check_replace_manifest $MANIFEST $replace_manifest
copy_template_manifest $template_cr $MANIFEST $profile

cr_env $template_cr $env_file $MANIFEST $profile
check_return_code $?

# postprocess manifest with dynamic clickhouse host list
update_clickhouse_hosts $MANIFEST $profile

echo updated core manifest $MANIFEST, profile $profile
