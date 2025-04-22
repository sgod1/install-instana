#!/bin/bash

source ../instana.env
source ./install.env
source ./datastore-images.env
source ./help-functions.sh
source ./cr-env.sh

function agent_yaml_yqmeta_preprocess() {
   local template=$1
   local manifest=$2

   cat $template \
   | sed 's/^  configuration\.yaml:.*/  configuration\.yaml:/' \
   | sed 's/^  configuration-opentelemetry\.yaml:.*/  configuration-opentelemetry\.yaml:/' \
   | sed 's/^  configuration-disable-kubernetes-sensor\.yaml:.*/  configuration-disable-kubernetes-sensor\.yaml:/' \
   | awk '{print "  " $0;}' | sed 's/^  ---/-/'| awk '
$0~/^-/ {print $0; print "  yqmeta:"}
$0!~/^-/ {print $0}
' | gen/bin/yq 'with(.[]; .yqmeta=.kind + "-" + .metadata.name)' | tee $manifest
}

function agent_yaml_yqmeta_postprocess() {
   local manifest=$1

   cat $manifest \
   | sed 's/^- yqmeta:.*/---/' | sed 's/^  //' \
   | sed 's/^  configuration\.yaml:/  configuration\.yaml: |/' \
   | sed 's/^  configuration-opentelemetry\.yaml:/  configuration-opentelemetry\.yaml: |/' \
   | sed 's/^  configuration-disable-kubernetes-sensor\.yaml:/  configuration-disable-kubernetes-sensor\.yaml: |/' \
   | tee $manifest > /dev/null
}

platform=$1
agent_cluster=$2
agent_zone=$3
agent_profile=${4:-"$INSTANA_INSTALL_PROFILE"}

usage="cr-agent.env ocp|k8s cluster zone [profile]"

if [[ -z $agent_cluster ]]; then
   echo "agent cluster argument required, usage: $usage"
   exit 1
fi

if [[ -z $agent_zone ]]; then
   echo "agent zone argument required, usage: $usage"
   exit 1
fi

# select input template
if [[ $platform == "ocp" ]]; then
   template_cr="agent-template-ocp.yaml"
   yqmeta_cr="yqmeta-ocp.yaml"

elif [[ $platform == "k8s" ]]; then
   template_cr="agent-template-k8s.yaml"
   yqmeta_cr="yqmeta-k8s.yaml"

else
   echo "invalid platform argument $platform, usage: $usage"
   exit 1
fi

if [[ ! -f $template_cr ]]; then
   echo "template $template_cr not found"
   exit 1
fi

# base64 encoded ?
export download_key=`echo $DOWNLOAD_KEY | base64`
# todo: add agent key to instana.env
export agent_key=`echo $AGENT_KEY | base64`

# todo: externalize
export agent_image="$PRIVATE_REGISTRY/instana/agent:latest"
export agent_sensor_image="$PRIVATE_REGISTRY/instana/k8sensor:latest"
export agent_cluster_name="$agent_cluster"

export instana_agent_endpoint=$(instana_agent_acceptor $INSTANA_BASE_DOMAIN)
export instana_agent_endpoint_port=${AGENT_ACCEPTOR_PORT:-"443"}
export sensor_backend_url="${instana_agent_endpoint}:${instana_agent_endpoint_port}"

env_file="agent-env.yaml"

OUT_DIR=$(get_make_manifest_home)

MANIFEST=$(format_file_path $OUT_DIR "instana-agent-${agent_cluster}-${agent_zone}.yaml" $agent_profile $INSTANA_VERSION)

# preprocess template_cr to yqmeta_cr
yqmeta_cr_path=$(format_file_path $OUT_DIR "instana-agent-${agent_cluster}-${agent_zone}-${yqmeta_cr}" $agent_profile $INSTANA_VERSION)
agent_yaml_yqmeta_preprocess $template_cr $yqmeta_cr_path
check_return_code $?

# too many args, skip...
#check_replace_manifest $MANIFEST $replace_manifest
copy_template_manifest $yqmeta_cr_path $MANIFEST $agent_profile

cr_env $yqmeta_cr_path $env_file $MANIFEST $agent_profile
check_return_code $?

# postprocess manifest
agent_yaml_yqmeta_postprocess $MANIFEST

echo updated agent manifest $MANIFEST, profile $agent_profile
