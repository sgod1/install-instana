#!/bin/bash

source ../instana.env

_raw_spans="rawSpans"
_synthetics="synthetics"
_synthetics_keystore="syntheticsKeystore"
_eum_source_maps="eumSourceMaps"

function write_pvc_storage_config() {
   local storage=$1 # raw_spans|synthetics|synthetics_keystore|eum_source_maps
   local config_yaml=$2

cat <<EOF >> $config_yaml
  $storage:
    pvcConfig:
      accessModes: 
        - ReadWriteMany
      resources:
        requests:
          storage: 10Gi
      storageClassName: $RWX_STORAGECLASS

EOF
}

function write_s3_storage_config() {
   local storage=$1 # raw_spans|synthetics|synthetics_keystore|eum_source_maps
   local config_yaml=$2

   if [[ $storage == "$_raw_spans" ]]; then
      endpoint=${core_config_raw_spans_s3_endpoint}
      region=${core_config_raw_spans_s3_region}
      bucket=${core_config_raw_spans_s3_bucket}
      prefix=${core_config_raw_spans_s3_prefix}
      storageClass=${core_config_raw_spans_s3_storage_class}
      bucketLongTerm=${core_config_raw_spans_s3_bucket_long_term}
      storageClassLongTerm=${core_config_raw_spans_s3_storage_class_long_term}
      forcePathStyle=${core_config_raw_spans_s3_force_path_style}
      accessKeyId=${core_config_raw_spans_s3_access_key_id}
      secretAccessKey=${core_config_raw_spans_s3_secret_access_key}

   elif [[ $storage == "$_synthetics" ]]; then
      endpoint=${core_config_synthetics_s3_endpoint}
      region=${core_config_synthetics_s3_region}
      bucket=${core_config_synthetics_s3_bucket}
      prefix=${core_config_synthetics_s3_prefix}
      storageClass=${core_config_synthetics_s3_storage_class}
      bucketLongTerm=${core_config_synthetics_s3_bucket_long_term}
      storageClassLongTerm=${core_config_synthetics_s3_storage_class_long_term}
      forcePathStyle=${core_config_synthetics_s3_force_path_style}
      accessKeyId=${core_config_synthetics_s3_access_key_id}
      secretAccessKey=${core_config_synthetics_s3_secret_access_key}

   elif [[ $storage == "$_synthetics_keystore" ]]; then
      endpoint=${core_config_synthetics_keystore_s3_endpoint}
      region=${core_config_synthetics_keystore_s3_region}
      bucket=${core_config_synthetics_keystore_s3_bucket}
      prefix=${core_config_synthetics_keystore_s3_prefix}
      storageClass=${core_config_synthetics_keystore_s3_storage_class}
      bucketLongTerm=${core_config_synthetics_keystore_s3_bucket_long_term}
      storageClassLongTerm=${core_config_synthetics_keystore_s3_storage_class_long_term}
      forcePathStyle=${core_config_synthetics_keystore_s3_force_path_style}
      accessKeyId=${core_config_synthetics_keystore_s3_access_key_id}
      secretAccessKey=${core_config_synthetics_keystore_s3_secret_access_key}

   elif [[ $storage == "$_eum_source_maps" ]]; then
      endpoint=${core_config_eum_source_maps_s3_endpoint}
      region=${core_config_eum_source_maps_s3_region}
      bucket=${core_config_eum_source_maps_s3_bucket}
      prefix=${core_config_eum_source_maps_s3_prefix}
      storageClass=${core_config_eum_source_maps_s3_storage_class}
      bucketLongTerm=${core_config_eum_source_maps_s3_bucket_long_term}
      storageClassLongTerm=${core_config_eum_source_maps_s3_storage_class_long_term}
      forcePathStyle=${core_config_eum_source_maps_s3_force_path_style}
      accessKeyId=${core_config_eum_source_maps_s3_access_key_id}
      secretAccessKey=${core_config_eum_source_maps_s3_secret_access_key}

   fi

#S3Config:
#struct{Endpoint string "json:"endpoint""; Region string "json:"region""; Bucket string "json:"bucket""; Prefix string "json:"prefix""; StorageClass string "json:"storageClass""; BucketLongTerm string "json:"bucketLongTerm,omitempty""; PrefixLongTerm string "json:"prefixLongTerm,omitempty""; StorageClassLongTerm string "json:"storageClassLongTerm,omitempty""; ForcePathStyle bool "json:"forcePathStyle,omitempty""; AccessKeyId string "json:"-" yaml:"accessKeyId""; SecretAccessKey string "json:"-" yaml:"secretAccessKey""}

cat <<EOF >> $config_yaml
  $storage:
    s3Config:
      endpoint: $endpoint
      region: $region
      bucket: $bucket
      prefix: $prefix
      storageClass: $storageClass
      bucketLongTerm: $bucketLongTerm
      prefixLongTerm: $prefixLongTerm
      storageClassLongTerm: $storageClassLongTerm
      forcePathStyle: $forcePathStyle
      accessKeyId: $accessKeyId
      secretAccessKey: $secretAccessKey

EOF

}

function write_gcloud_storage_config() {
   local storage=$1 # raw_spans|synthetics|synthetics_keystore|eum_source_maps
   local config_yaml=$2

   if [[ $storage == "$_raw_spans" ]]; then
      bucket=${core_config_raw_spans_gcloud_bucket}
      prefix=${core_config_raw_spans_gcloud_prefix}
      storageClass=${core_config_raw_spans_gcloud_storage_class}
      bucketLongTerm=${core_config_raw_spans_gcloud_bucket_long_term}
      prefixLongTerm=${core_config_raw_spans_gcloud_prefix_long_term}
      storageClassLongTerm=${core_config_raw_spans_gcloud_storage_class_long_term}
      serviceAccountKey=${core_config_raw_spans_gcloud_service_account_key}

   elif [[ $storage == "$_synthetics" ]]; then
      bucket=${core_config_synthetics_gcloud_bucket}
      prefix=${core_config_synthetics_gcloud_prefix}
      storageClass=${core_config_synthetics_gcloud_storage_class}
      bucketLongTerm=${core_config_synthetics_gcloud_bucket_long_term}
      prefixLongTerm=${core_config_synthetics_gcloud_prefix_long_term}
      storageClassLongTerm=${core_config_synthetics_gcloud_storage_class_long_term}
      serviceAccountKey=${core_config_synthetics_gcloud_service_account_key}

   elif [[ $storage == "$_synthetics_keystore" ]]; then
      bucket=${core_config_synthetics_keystore_gcloud_bucket}
      prefix=${core_config_synthetics_keystore_gcloud_prefix}
      storageClass=${core_config_synthetics_keystore_gcloud_storage_class}
      bucketLongTerm=${core_config_synthetics_keystore_glcoud_bucket_long_term}
      prefixLongTerm=${core_config_synthetics_keystore_gcloud_prefix_long_term}
      storageClassLongTerm=${core_config_synthetics_keystore_gcloud_storage_class_long_term}
      serviceAccountKey=${core_config_synthetics_keystore_gcloud_service_account_key}

   elif [[ $storage == "$_eum_source_maps" ]]; then
      bucket=${core_config_eum_source_maps_gcloud_bucket}
      prefix=${core_config_eum_source_maps_gcloud_prefix}
      storageClass=${core_config_eum_source_maps_gcloud_storage_class}
      bucketLongTerm=${core_config_eum_source_maps_gcloud_bucket_long_term}
      prefixLongTerm=${core_config_eum_source_maps_gcloud_prefix_long_term}
      storageClassLongTerm=${core_config_eum_source_maps_gcloud_storage_class_long_term}
      serviceAccountKey=${core_config_eum_source_maps_gcloud_service_account_key}

   fi

#GCloudConfig 
#struct{Bucket string "json:"bucket""; Prefix string "json:"prefix""; StorageClass string "json:"storageClass""; BucketLongTerm string "json:"bucketLongTerm,omitempty""; PrefixLongTerm string "json:"prefixLongTerm,omitempty""; StorageClassLongTerm string "json:"storageClassLongTerm,omitempty""; ServiceAccountKey string "json:"-" yaml:"serviceAccountKey""}

cat <<EOF >> $config_yaml
  $storage:
    gcloudConfig:
      bucket: $bucket
      prefix: $prefix
      storageClass: $storageClass
      bucketLongTerm: $bucketLongTerm
      prefixLongTerm: $prefixLongTerm
      storageClassLongTerm: $storageClassLongTerm
      serviceAccountKey: $serviceAccountKey

EOF

}

function write_storage_config() {
   local storage=$1 # raw_spans|synthetics|synthetics_keystore|eum_source_maps
   local storage_config=$2 # pvc|raw_spans|gcloud
   local config_yaml=$3

   echo cr-core-storage: $storage, $storage_config

   if [[ $storage_config == "pvc" ]]; then
      write_pvc_storage_config $storage $config_yaml

   elif [[ $storage_config == "s3" ]]; then
      write_s3_storage_config $storage $config_yaml

   elif [[ $storage_config == "gcloud" ]]; then
      write_gcloud_storage_config $storage $config_yaml

   fi
}

#
# main
#

cr_yaml=$1

if [[ -z $cr_yaml ]]; then
   echo cr-core-storage: core file parameter required
   exit 1
fi

if [[ ! -f $cr_yaml ]]; then
   echo cr-core-storage: input core file $cr_yaml not found...
   exit 1
fi

config_yaml="./gen/core_storage_configs.yaml"

cat <<EOF > $config_yaml
storageConfigs:
EOF

# CORE_CONFIG_RAW_SPANS_STORAGE="s3|gcloud|pvc"
# CORE_CONFIG_SYNTHETICS_STORAGE="s3|gloud|pvc"
# CORE_CONFIG_SYNTHETICS_KEYSTORE_STORAGE="s3|gcloud|pvc"
# CORE_CONFIG_EUM_SOURCE_MAPS_STORAGE="s3|gcloud|pvc"

write_storage_config "$_raw_spans" $CORE_CONFIG_RAW_SPANS_STORAGE $config_yaml
write_storage_config "$_synthetics" $CORE_CONFIG_SYNTHETICS_STORAGE $config_yaml 
write_storage_config "$_synthetics_keystore" $CORE_CONFIG_SYNTHETICS_KEYSTORE_STORAGE $config_yaml 
write_storage_config "$_eum_source_maps" $CORE_CONFIG_EUM_SOURCE_MAPS_STORAGE $config_yaml

# delete .spec.storageConfigs from cr_yaml
./gen/bin/yq -i "del(.spec.storageConfigs)" $cr_yaml

# inject core_storage_config_yaml
./gen/bin/yq -i ".spec += (load(\"$config_yaml\"))" $cr_yaml

# delete config_yaml
rm $config_yaml
