#!/bin/bash

source ./help-functions.sh

if [[ -f ../installer.env ]]; then
source ../installer.env
fi

export PATH=".:$PATH"

# install/uninstall
install_type=$1

if [[ -z $install_type ]]; then
   echo install type argument required: install/uninstall
   exit 1
fi

if [[ $install_type == install ]]; then

   if [[ -z $skip_download_cli_tools ]]; then
      display_install_header download cli tools

      0-wget-cli-tools.sh
      check_return_code $?

   else
      display_install_header skip cli tools downlad
   fi

   if [[ -z $skip_install_cli_tools ]]; then
      display_install_header install cli tools

      0-install-cli-tools.sh
      check_return_code $?

   else
      display_install_header skip cli tools install
   fi

   if [[ -z $skip_generate_mirror_scripts ]]; then
      display_install_header generate and run mirror scripts

      1-generate-mirror-scripts.sh ${run_mirror_scripts:-"norun"}
      check_return_code $?

   else
      display_install_header skip generate mirror scripts
   fi

   if [[ -z $skip_generate_manifests ]]; then
      display_install_header generate manifests

      2-generate-manifests.sh ${replace_manifets:-"noreplace"}
      check_return_code $?

   else
      display_install_header skip generate manifests
   fi

   if [[ -z $skip_pull_datastore_charts ]]; then
      display_install_header pull datastore charts

      3-pull-datastore-charts.sh
      check_return_code $?

   else
      display_install_header skip pull datastore charts
   fi

   if [[ -z $skip_instana_install ]]; then
      display_install_header install instana

      4-install.sh
      check_return_code $?

   else
      display_install_header skip instana install
   fi

elif [[ $install_type == uninstall ]]; then
	echo uninstall not implemented
	exit 0
else
   echo "invalid install type argument $1... values: install/uninstall"
   exit 1
fi
