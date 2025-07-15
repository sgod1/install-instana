#!/bin/bash

source ../instana.env
source ./help-functions.sh
source ./install.env

imglist=$1

if [[ ! -f $imglist ]]; then
   echo image list $imglist not found...
   exit 1
fi

__username=$PRIVATE_REGISTRY_USER 
__password=$PRIVATE_REGISTRY_PASSWORD 
__registry=$PRIVATE_DOCKER_SERVER

$PODMAN login $PODMAN_TLS_VERIFY --username $__username --password $__password  $__registry
rc=$?
if [[ $rc > 0 ]]; then 
   echo error: failed to login into container registry $__registry, rc=$rc
   exit $rc; 
fi

log=${imglist}_push.log
cat /dev/null > $log

echo logged into container registry $__registry, username $__username >> $log
cat $log

ir=`echo "$INSTANA_REGISTRY" | sed 's/[.]/\\\\./g'`
tr=`echo "$PRIVATE_REGISTRY" | sed 's/[.]/\\\\./g'`

cat $imglist | while read image 
do 
   image=`echo $image | xargs`
   if [[ "$image" =~ ^#.* ]]; then continue; fi

   ti=`echo "$image" | sed "s/$ir/$tr/g"`

   set -x

   echo "$PODMAN push $PODMAN_TLS_VERIFY $ti" >> $log

   $PODMAN push $PODMAN_TLS_VERIFY $ti

   rc=$?
   if [[ $rc > 0 ]]; then 
      echo "error: image push failed... $PODMAN push $PODMAN_TLS_VERIFY $ti, rc=$rc"
      exit $rc; 
   fi
done

echo "image push complete... push log $log"

