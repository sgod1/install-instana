#!/bin/bash

source ../instana.env
source ./help-functions.sh
source ./install.env

imglist=$1

if [[ ! -f $imglist ]]; then
   echo image list $imglist not found...
   exit 1
fi

IMG_PLATFORM="--platform $(podman_image_platform $PODMAN_IMG_PLATFORM)"

#
# login into instana container registry or registry proxy
#
if [[ $INSTANA_REGISTRY_PROXY ]]; then
   __username="$INSTANA_REGISTRY_PROXY_USER"
   __password="$INSTANA_REGISTRY_PROXY_PASSWORD"
   __registry="$INSTANA_REGISTRY_RPOXY"
   echo pull images: logging into registry proxy... $__registry
else
   __username="_"
   __password="$DOWNLOAD_KEY"
   __registry="$INSTANA_REGISTRY"
   echo pull images: logging into instana registry... $__registry
fi

if [[ -z $__registry ]]; then
   echo pull images: $PODMAN login registry undefined...
   exit 1
fi

if [[ -z $__username ]]; then
   echo pull images: $PODMAN login username undefined...
   exit 1
fi

if [[ -z $__password ]]; then
   __password_arg=""
else
   __password_arg="--password $__password"
fi

$PODMAN login $PODMAN_TLS_VERIFY --username $__username $__password_arg  $__registry
rc=$?
if [[ $rc > 0 ]]; then 
   echo error: failed to login into container registry $__registry, rc=$rc
   exit $rc; 
fi

set -x

log=${imglist}_pull.log
cat /dev/null > $log

if [[ ! -z $INSTANA_REGISTRY_PROXY ]]; then
   echo logged into container registry proxy $__registry, username $__username >> $log
else
   echo logged into container registry $__registry, username $__username >> $log
fi

cat $log

#
# pull images
#
ir=`echo "$INSTANA_REGISTRY" | sed 's/[.]/\\\\./g' | sed 's/\//\\\\\//g'`
pr=`echo "$__registry" | sed 's/[.]/\\\\./g' | sed 's/\//\\\\\//g'`

cat $imglist | while read image
do 
   image=`echo $image | xargs`
   if [[ -z $image || $image =~ ^#.* ]]; then continue; fi

   # if pulling from proxy registry, substitue instana registry
   image=`echo "$image" | sed "s/$ir/$pr/g"`

   echo "$PODMAN pull $IMG_PLATFORM $image" >> $log

   $PODMAN pull $IMG_PLATFORM $image
   rc=$?
   if [[ $rc > 0 ]]; then 
      echo error: image pull $IMG_PLATFORM $image failed, rc=$rc
      exit $rc; 
   fi
done

echo "image pull complete... pull log $log"
