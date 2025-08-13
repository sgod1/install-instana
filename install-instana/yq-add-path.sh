#!/bin/bash

# add yaml file under the addpath into out yaml

addpath=$1
addyaml=$2
outyaml=$3

rc=0

if [[ `./gen/bin/yq eval "$addpath" "$outyaml"` == null ]]; then
  echo "adding path $addpath to $outyaml"
  ./gen/bin/yq -i "$addpath += (load(\"$addyaml\"))" $outyaml
  rc=$?

else
  echo file $outyaml already contains path $addpath, skip...
fi

exit $rc
