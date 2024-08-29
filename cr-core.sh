#!/bin/bash

source ../instana.env
source ./help-functions.sh

MANIFEST_HOME=$(get_manifest_home)
MANIFEST=$MANIFEST_HOME/$MANIFEST_FILENAME_CORE

echo writing core manifest to $MANIFEST

function write_api_header() {
manifest=$1
cat << EOF > $manifest
apiVersion: instana.io/v1beta2
kind: Core
metadata:
  namespace: instana-core
  name: instana-core
spec:
EOF
}

function write_base_domain() {
manifest=$1
cat << EOF >> $manifest
  # The domain under which Instana is reachable
  baseDomain: $INSTANA_BASE_DOMAIN

EOF
}

function write_image_pull_secrets() {
manifest=$1
cat << EOF >> $manifest
  # Depending on your cluster setup, you may need to specify an image pull secret.
  imagePullSecrets:
    - name: instana-registry

EOF
}

function write_image_config() {
manifest=$1
cat << EOF >> $manifest
  imageConfig:
    registry: $PRIVATE_REGISTRY

EOF
}

function write_feature_flags() {
manifest=$1
cat << EOF >> $manifest
  featureFlags:
    - name: beeinstana
      enabled: true
    - name: feature.beeinstana.enabled
      enabled: true
    - name: feature.beeinstana.infra.metrics.enabled
      enabled: true
    - name: feature.automation.enabled
      enabled: true
    - name: feature.business.observability.enabled
      enabled: true
    - name: feature.logging.enabled
      enabled: true
    - name: feature.synthetics.enabled
      enabled: true
    #- name: feature.openstack.enabled
    #  enabled: true
    #- feature: feature.pcf.enabled
    #  enabled: true
    #- feature: feature.vsphere.enabled
    #  enabled: true

EOF
}

function write_operational_modes() {
manifest=$1
cat << EOF >> $manifest
  # operational modes
  operationMode: normal

EOF
}

function write_operation_scopes() {
manifest=$1

# applies to saas type install

if test $CUSTOM_EDITION_SAAS_INSTALL; then
cat << EOF >> $manifest
  #operationScopes:
  #- core
  #- global

EOF
fi
}

function write_email_config() {
manifest=$1
cat << EOF >> $manifest
  # This configures an SMTP server for sending e-mails.
  # Alternatively, Amazon SES is supported. Please see API reference for details.
  emailConfig:
    smtpConfig:
      from: smtp@example.com
      host: smtp.example.com
      port: 465
      useSSL: false
      startTLS: false

EOF
}

function write_image_acceptor_config() {
manifest=$1
cat << EOF >> $manifest
  agentAcceptorConfig:
    host: $INSTANA_AGENT_ACCEPTOR
    port: 443

EOF
}

function write_storage_configs_header() {
manifest=$1
cat << EOF >> $manifest
  storageConfigs:
EOF
}

function _write_raw_spans_s3() {
manifest=$1
cat << EOF >> $manifest
      s3Config:
        # S3 Endpoint Ref: https://docs.aws.amazon.com/general/latest/gr/s3.html#s3_region (optional)
        endpoint: "$RAW_SPANS_S3_ENDPOINT"
        region: "$RAW_SPANS_S3_REGION"
        bucket: "$RAW_SPANS_S3_BUCKET"
        prefix: "$RAW_SPANS_S3_PREFIX"
        storageClass: "$RAW_SPANS_S3_STORAGE_CLASS"
        bucketLongTerm: "$RAW_SPANS_S3_BUCKET_LONG_TERM"
        prefixLongTerm: "$RAW_SPANS_S3_PREFIX_LONG_TERM"
        storageClassLongTerm: "$RAW_SPANS_S3_STORAGE_CLASS_LONG_TERM"

EOF
}

function _write_raw_spans_pvc() {
manifest=$1
cat << EOF >> $manifest
      pvcConfig:
        accessModes: 
          - ReadWriteMany
        resources:
          requests:
            storage: 100Gi
        storageClassName: $RWX_STORAGECLASS

EOF
}

function write_storage_config_raw_spans() {
manifest=$1

cat << EOF >> $manifest
    rawSpans:

EOF

if test $RAW_SPANS_TYPE == $RAW_SPANS_TYPE_S3; then
   _write_raw_spans_s3 $manifest

elif test $RAW_SPANS_TYPE == $RAW_SPANS_TYPE_PVC; then
   _write_raw_spans_pvc $manifest

else
   echo unexpected raw span storage type $RAW_SPAN_TYPE
   exit 1
fi

}

function write_storage_config_synthetics() {
manifest=$1
cat << EOF >> $manifest
    synthetics:
      pvcConfig:
        accessModes:
          - ReadWriteMany
        resources:
          requests:
            storage: 50Gi
        storageClassName: ${RWX_STORAGECLASS}

    syntheticsKeystore:
      pvcConfig:
        accessModes:
          - ReadWriteMany
        resources:
          requests:
            storage: 10Gi
        storageClassName: ${RWX_STORAGECLASS}

EOF
}

function write_datastore_configs() {
manifest=$1
cat << EOF >> $manifest
  datastoreConfigs:
    cassandraConfigs:
      - hosts:
          - instana-cassandra-service.instana-cassandra.svc
        authEnabled: true
        datacenter: cassandra

    clickhouseConfigs:
      - hosts:
        - chi-instana-local-0-0.instana-clickhouse.svc
        - chi-instana-local-0-1.instana-clickhouse.svc
        authEnabled: true
        clusterName: local
        # ports: [{name:"tcp", port:"9000"},{name:"http", port:"8123"}]

    postgresConfigs:
      - hosts:
        - postgres-rw.instana-postgres.svc
        authEnabled: true

    elasticsearchConfig:
      authEnabled: true
      clusterName: instana
      # ports: [{name:"tcp", port:"9300"},{name:"http", port:"9200"}]
      hosts:
      - instana-es-http.instana-elasticsearch.svc

    beeInstanaConfig:
      authEnabled: true
      clustered: true
      hosts:
      - aggregators.beeinstana.svc
      ports:
      - name: tcp
        port: 9998

    kafkaConfig:
      authEnabled: true
      saslMechanism: SCRAM-SHA-512
      hosts:
      - instana-kafka-bootstrap.instana-kafka.svc

EOF
}

function write_service_account_annotations() {
manifest=$1

if test $PLATFORM == $PLATFORM_EKS; then
cat << EOF >> $manifest
  serviceAccountAnnotations:
    eks.amazonaws.com/role-arn: "$AWS_EKS_ROLE_ARN"

EOF
fi
}

function write_resource_profile() {
manifest=$1
cat << EOF >> $manifest
  resourceProfile: $CORE_RESOURCE_PROFILE

EOF
}

function write_properties() {
manifest=$1
cat << EOF >> $manifest
  properties:
    # retention settings
    - name: retention.metrics.rollup5
      value: "86400"
    - name: retention.metrics.rollup60
      value: "2678400"
    - name: retention.metrics.rollup300
      value: "8035200"
    - name: retention.metrics.rollup3600
      value: "34214400"
    - name: config.appdata.shortterm.retention.days
      value: "7"
    - name: config.synthetics.retention.days
      value: "60"

EOF
}

# write core manifest

write_api_header $MANIFEST
write_base_domain $MANIFEST
write_image_pull_secrets $MANIFEST
write_image_config $MANIFEST
write_feature_flags $MANIFEST
write_operational_modes $MANIFEST
write_operation_scopes $MANIFEST
write_email_config $MANIFEST
write_image_acceptor_config $MANIFEST
write_storage_configs_header $MANIFEST
write_storage_config_raw_spans $MANIFEST
write_storage_config_synthetics $MANIFEST
write_datastore_configs $MANIFEST
write_service_account_annotations $MANIFEST
write_resource_profile $MANIFEST
write_properties $MANIFEST

