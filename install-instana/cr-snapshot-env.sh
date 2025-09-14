#!/bin/bash

source ../instana.env
source ./help-functions.sh

export PATH=".:$PATH"

snapshot_home=$(get_make_snapshot_home)

env_file_in=$1
yaml_file_in=$2

# profile
profile=${3:-$INSTANA_INSTALL_PROFILE}

# output env file
oef=`echo ${env_file_in} | cut -d "." -d "/" -f 2 | cut -d "." -f 1`
env_file_out="$snapshot_home/${oef}-snapshot.yaml"

function copy_input_env() {
   echo "copying input env $env_file_in to $env_file_out"
   cp $env_file_in $env_file_out
}

function postprocess_out_env() {
   local baseout=`basename $env_file_out`
   cp $env_file_out /tmp/$baseout
   sed '/^$/d' /tmp/$baseout > $env_file_out
   rm /tmp/$baseout

   echo ""
   echo "env snapshot output written to: $env_file_out"
   echo ""
}

function snapshot_env() {
   local path_names=`./gen/bin/yq ".env[] | .name" $env_file_in`
   local path_name=""

   for path_name in $path_names; do
      echo ===
      echo path name $path_name, env file $env_file_in

      local path=`./gen/bin/yq ".env[] | select(.name == \"$path_name\") | .path" $env_file_in | tr -d "\n "`
      echo "path: $path"

      # apply path to input yaml
      val=$(./gen/bin/yq "$path" $yaml_file_in)
      echo $profile: $val

      # query update path
      local envpath=`./gen/bin/yq eval ".env[] | select(.name == \"$path_name\") | .values | .${profile}-snapshot | path | \".\" + join(\".\")" $env_file_in`

      # update output env file
      echo "updating env path $envpath, env file $env_file_out, value $val"

      ./gen/bin/yq -i "$envpath |= \"$val\"" $env_file_out

   done
}

#
# main
#

if [[ ! -f $env_file_in ]]; then
   echo "input env file $env_file_in not found..."
   exit 1
fi

if [[ ! -f $yaml_file_in ]]; then
   echo "input yaml file $yaml_file_in not found..."
   exit 1
fi

if [[ -z $profile ]]; then
   echo "profile value undefined, setting profile to default"
   profile="default"
fi

copy_input_env
snapshot_env
postprocess_out_env

