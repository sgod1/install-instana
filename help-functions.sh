#!/bin/bash

compare_values() {
   test ${1:-"novalue1"} == ${2:-"novalue2"}
}

check_return_code() {
   if [ $1 -gt 0 ]; then echo "exit on script error, rc $1"; exit $1; fi
}

function get_install_home() {
   echo ${INSTANA_INSTALL_HOME:-"gen"}
}

function get_make_install_home() {
   install_home=$(get_install_home)
   mkdir -p "$install_home"
   echo "$install_home"
}

function get_mirror_home() {
   install_home=$(get_install_home)
   echo "$install_home/mirror"
}

function get_make_mirror_home() {
   mirror_home=$(get_mirror_home)
   mkdir -p $mirror_home
   echo "$mirror_home"
}

function get_bin_home() {
   install_home=$(get_install_home)
   echo "$install_home/bin"
}

function get_make_bin_home() {
   bin_home=$(get_bin_home)
   mkdir -p "$bin_home"
   echo "$bin_home"
}

function get_manifest_home() {
   manifest_home=$(get_install_home)
   echo $manifest_home
}

function get_make_manifest_home() {
   manifest_home=$(get_manifest_home)
   mkdir -p "$manifest_home"
   echo "$manifest_home"
}

function get_chart_home() {
   chart_home=$(get_install_home)
   echo "$chart_home/charts"
}

function get_make_chart_home() {
   chart_home=$(get_chart_home)
   mkdir -p "$chart_home"
   echo "$chart_home"
}
