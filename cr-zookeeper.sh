#!/bin/bash

source ../instana.env
source ./help-functions.sh
source ./datastore-images.env

OUT_DIR=$(get_make_manifest_home)
MANIFEST="$OUT_DIR/$MANIFEST_FILENAME_ZOOKEEPER"

replace_manifest=${1:-"noreplace"}

check_replace_manifest $MANIFEST $replace_manifest

echo writing zookeeper to $MANIFEST

zookeeper_img_repo=`echo ${ZOOKEEPER_IMG} | cut -d : -f 1 -`
zookeeper_img_tag=`echo ${ZOOKEEPER_IMG} | cut -d : -f 2 -`

cat << EOF > $MANIFEST
apiVersion: "zookeeper.pravega.io/v1beta1"
kind: "ZookeeperCluster"
metadata:
  name: "instana-zookeeper"

spec:
  # For parameters and default values, see https://github.com/pravega/zookeeper-operator/tree/master/charts/zookeeper#configuration
  replicas: 3
  image:
    repository: ${PRIVATE_REGISTRY}/${zookeeper_img_repo}
    tag: ${zookeeper_img_tag}

  pod:
    imagePullSecrets: [name: "instana-registry"]
    serviceAccountName: "zookeeper"

EOF

if ! is_platform_ocp "$PLATFORM"; then
cat << EOF >> $MANIFEST
    # Add the following securityContext snippet for Kubernetes offerings other than OCP.
    securityContext:
      runAsUser: 1000
      fsGroup: 1000

EOF
fi

cat << EOF >> $MANIFEST
  config:
    tickTime: 2000
    initLimit: 10
    syncLimit: 5
    maxClientCnxns: 0
    autoPurgeSnapRetainCount: 20
    autoPurgePurgeInterval: 1

  persistence:
    reclaimPolicy: Delete
    spec:
      resources:
        requests:
          storage: "10Gi"
      storageClassName: $RWO_STORAGECLASS
EOF

