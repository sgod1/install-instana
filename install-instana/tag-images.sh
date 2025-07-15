#!/bin/bash

source ../instana.env
source ./help-functions.sh
source ./install.env

imglist=$1

if [[ ! -f $imglist ]]; then
   echo image list $imglist not found...
   exit 1
fi

#
# tag images
#

ir=`echo "$INSTANA_REGISTRY" | sed 's/[.]/\\\\./g'`
tr=`echo "$PRIVATE_REGISTRY" | sed 's/[.]/\\\\./g'`
pr=`echo "${INSTANA_REGISTRY_PROXY:-$INSTANA_REGISTRY}" | sed 's/[.]/\\\\./g'`

log=${imglist}_tag.log
cat /dev/null > $log

cat $imglist | while read image 
do 
   image=`echo $image | xargs`
   if [[ -z $image || $image =~ ^#.* ]]; then continue; fi

   # if proxy registry, substitute instana registry with proxy registry
   image=`echo "$image" | sed "s/$ir/$pr/g"`

   ti=`echo "$image" | sed "s/$ir/$tr/g"`

   set -x

   echo "$PODMAN tag $image $ti" >> $log

   $PODMAN tag $image $ti

   rc=$?
   if [[ $rc > 0 ]]; then 
      echo "error: image tag failed... $PODMAN tag $image $ti, rc=$rc"
      exit $rc; 
   fi
done

echo "image tag complete... tag log $log"
