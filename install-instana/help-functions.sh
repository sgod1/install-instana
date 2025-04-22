#!/bin/bash

compare_values() {
   test ${1:-"novalue1"} = ${2:-"novalue2"}
}

check_return_code() {
   if [[ $1 > 0 ]]; then echo "exit on script error, rc $1"; exit $1; fi
}

check_replace_manifest() {
   local manifest=${1:-"missingvalue"}
   local replace_manifest=${2:-"missingvalue"}

   if test -f $manifest; then
      if [[ $replace_manifest == "replace" ]]; then
      #if compare_values "$replace_manifest" "replace"; then
         echo backup "$manifest" to "${manifest}.bak"
         cp "$manifest" "${manifest}.bak"
      else
         echo manifest $manifest already exists, use \"replace\" argument to replace manifest
         echo
         exit 1
      fi
   fi
}

check_replace_manifest_dir() {
   local manifest_dir=${1:-"missingvalue"}
   local replace_manifest_dir=${2:-"missingvalue"}

   if test -d $manifest_dir; then
      if compare_values "$replace_manifest_dir" "replace"; then
         echo backup "$manifest_dir" to "${manifest_dir}_bak"
         cp -r "$manifest_dir" "${manifest_dir}_bak"
      else
         echo manifest directory $manifest_dir already exists, use \"replace\" argument to replace manifest dir
         echo
         exit 1
      fi
   fi
}

function check_platform() {
   local platform=$1
   if test -z $platform; then
      echo platform value undefined
      exit 1
   fi
}

function is_platform_ocp() {
   local platform=$1
   check_platform $platform
   compare_values $platform "ocp"
}

function get_install_home() {
   echo ${INSTANA_INSTALL_HOME:-"./gen"}
}

function get_make_install_home() {
   local install_home=$(get_install_home)
   mkdir -p "$install_home"
   echo "$install_home"
}

function get_mirror_home() {
   instana_version=$1
   local install_home=$(get_install_home)
   if test "$instana_version"; then
      echo "$install_home/mirror/$instana_version"
   else
      echo "$install_home/mirror"
   fi
}

function get_make_mirror_home() {
   instana_version=$1
   local mirror_home=$(get_mirror_home $instana_version)
   mkdir -p $mirror_home
   echo "$mirror_home"
}

function get_bin_home() {
   local install_home=$(get_install_home)
   echo "$install_home/bin"
}

function get_make_bin_home() {
   local bin_home=$(get_bin_home)
   mkdir -p "$bin_home"
   echo "$bin_home"
}

function get_manifest_home() {
   local manifest_home=$(get_install_home)
   echo $manifest_home
}

function get_make_manifest_home() {
   local manifest_home=$(get_manifest_home)
   mkdir -p "$manifest_home"
   echo "$manifest_home"
}

function get_chart_home() {
   local chart_home=$(get_install_home)
   echo "$chart_home/charts"
}

function get_make_chart_home() {
   local chart_home=$(get_chart_home)
   mkdir -p "$chart_home"
   echo "$chart_home"
}

function get_snapshot_home() {
   local install_home=$(get_install_home)
   echo "$install_home/snapshots"
}

function get_make_snapshot_home() {
   local snapshot_home=$(get_snapshot_home)
   mkdir -p "$snapshot_home"
   echo "$snapshot_home"
}

function get_tls_home() {
   local install_home=$(get_install_home)
   echo "$install_home/tls"
}

function get_make_tls_home() {
   local tls_home=$(get_tls_home)
   mkdir -p "$tls_home"
   echo "$tls_home"
}

function snapshot_name() {
   local instana_version=$1
   echo pre-${instana_version}-upgrade-`date +%F-%H-%M-%S`
}

function write_install_profile_header() {
   local manifest=$1
   local profile=$2

   echo "#-- instana install profile: $profile" > $manifest
}

function copy_template_manifest() {
   local template=$1
   local manifest=$2
   local profile=$3

   write_install_profile_header $manifest $profile
   cat $template >> $manifest
}

function format_file_path() {
  local home=$1
  local filename=$2
  local profile=$3
  local instana_version=$4

  local name=`echo $filename | cut -d "." -f1`
  local ext=`echo $filename | cut -d "." -f2`

  #echo "${home}/${name}-${profile}-${instana_version}.${ext}"

  # name-version.ext
  echo "${home}/${name}-${instana_version}.${ext}"
}

function instana_tenant_domain() {
   local unit_name=$1
   local tenant_name=$2
   local base_domain=$3
   echo "${unit_name}-${tenant_name}.${base_domain}"
}

function instana_agent_acceptor() {
   local base_domain=$1
   echo "agent-acceptor.${base_domain}"
}

function instana_otlp_grpc_acceptor() {
   local base_domain=$1
   echo "otlp-grpc.${base_domain}"
}

function instana_otlp_http_acceptor() {
   local base_domain=$1
   echo "otlp-http.${base_domain}"
}

function private_registry() {
   local private_docker_server=$1
   local private_registry_subpath=$2
   echo "${private_docker_server}${private_registry_subpath}"
}

function podman_image_platform() {
   local platform=${1:-"--platform linux/amd64"}
   echo "${platform}"
}

function log_msg() {
   # calling script name not included
   echo "$@"
}

function log_msg0() {
   # calling script name included
   echo "$@"
}

function display_install_header() {
   local header=$*
   echo
   echo ~~~~~~~~~~~ $header
   echo
}
