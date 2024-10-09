#!/bin/bash

source ../instana.env
source ./help-functions.sh

MANIFEST_HOME=$(get_manifest_home)
MANIFEST=$MANIFEST_HOME/$MANIFEST_FILENAME_CORE

replace_manifest=${1:-"noreplace"}

check_replace_manifest $MANIFEST $replace_manifest

echo writing core manifest to $MANIFEST

cat << EOF > $MANIFEST
apiVersion: instana.io/v1beta2
kind: Core
metadata:
  namespace: instana-core
  name: instana-core

spec:
  # The domain under which Instana is reachable
  # required field
  baseDomain: ${INSTANA_BASE_DOMAIN:-"instana.base.domain"}

  # image pull secrets
  imagePullSecrets:
    - name: instana-registry

  imageConfig:
    registry: ${PRIVATE_REGISTRY:-"private.registry.com"}

  # optional features
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

  # operational modes
  operationMode: normal

  # operational scopes apply in saas environment
  #operationScopes:
  #- core
  #- global

  # This configures an SMTP server for sending e-mails.
  # Alternatively, Amazon SES is supported. Please see API reference for details.
  # required element
  emailConfig:
    smtpConfig:
      from: ${SMTP_FROM:-"from@example.com"}
      host: ${SMTP_HOST:-"smtp.example.com"}
      port: ${SMTP_PORT:-465}
      useSSL: ${SMTP_USE_SSL:-false}
      startTLS: ${SMTP_START_TLS:-false}

  agentAcceptorConfig:
    host: ${INSTANA_AGENT_ACCEPTOR:- "instana-agent-acceptor.example.com"}
    port: 443

  storageConfigs:
    rawSpans:
EOF

# raw spans
if compare_values "$RAW_SPANS_TYPE" "$RAW_SPANS_TYPE_PVC" || test -z "$RAW_SPANS_TYPE"; then
cat << EOF >> $MANIFEST
      pvcConfig:
        accessModes: 
          - ReadWriteMany
        resources:
          requests:
            storage: 100Gi
        storageClassName: ${RWX_STORAGECLASS:-"Standard"}

EOF
fi

if compare_values "$RAW_SPANS_TYPE" "$RAW_SPANS_TYPE_S3"; then
cat << EOF >> $MANIFEST
      s3Config:
        endpoint: ${RAW_SPANS_S3_ENDPOINT:-""}
        region: ${RAW_SPANS_S3_REGION:-"raw-spans-region"}
        bucket: ${RAW_SPANS_S3_BUCKET:-"raw-spans-bucket"}
        prefix: ${RAW_SPANS_S3_PREFIX:-"raw-spans-prefix"}
        storageClass: ${RAW_SPANS_S3_STORAGE_CLASS:-"Standard"}
        bucketLongTerm: ${RAW_SPANS_S3_BUCKET_LONG_TERM:-"raw-spans-bucket-long-term"}
        prefixLongTerm: ${RAW_SPANS_S3_PREFIX_LONG_TERM:-"raw-spans-prefix-long-term"}
        storageClassLongTerm: ${RAW_SPANS_S3_STORAGE_CLASS_LONG_TERM:-"Standard"}

EOF
fi

if compare_values "$RAW_SPANS_TYPE" "$RAW_SPANS_TYPE_GCP"; then
cat << EOF >> $MANIFEST
      gcloudConfig:
        endpoint: ${RAW_SPANS_S3_ENDPOINT:-""}
        region: ${RAW_SPANS_S3_REGION:-"raw-spans-region"}
        bucket: ${RAW_SPANS_S3_BUCKET:-"raw-spans-bucket"}
        prefix: ${RAW_SPANS_S3_PREFIX:-"raw-spans-prefix"}
        storageClass: ${RAW_SPANS_S3_STORAGE_CLASS:-"Standard"}
        bucketLongTerm: ${RAW_SPANS_S3_BUCKET_LONG_TERM:-"raw-spans-bucket-long-term"}
        prefixLongTerm: ${RAW_SPANS_S3_PREFIX_LONG_TERM:-"raw-spans-prefix-long-term"}
        storageClassLongTerm: ${RAW_SPANS_S3_STORAGE_CLASS_LONG_TERM:-"Standard"}

EOF
fi

cat << EOF >> $MANIFEST
    synthetics:
      pvcConfig:
        accessModes:
          - ReadWriteMany
        resources:
          requests:
            storage: 50Gi
        storageClassName: ${RWX_STORAGECLASS:-"Standard"}

    syntheticsKeystore:
      pvcConfig:
        accessModes:
          - ReadWriteMany
        resources:
          requests:
            storage: 10Gi
        storageClassName: ${RWX_STORAGECLASS:-"Standard"}

  # required element
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

    postgresConfigs:
      - hosts:
        - postgres-rw.instana-postgres.svc
        authEnabled: true

    elasticsearchConfig:
      authEnabled: true
      clusterName: instana
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

# service account annotations
if compare_values "$PLATFORM" "$PLATFORM_EKS"; then
cat << EOF >> $MANIFEST
  serviceAccountAnnotations:
    eks.amazonaws.com/role-arn: ${AWS_EKS_ROLE_ARN:-"arn:role:1"}

EOF
fi

if compare_values "$PLATFORM" "$PLATFORM_GCP"; then
cat << EOF >> $MANIFEST
  serviceAccountAnnotations:
    iam.gke.io/gcp-service-account: ${GCP_SERVICE_ACCOUNT:-"iam:gcp:service-account"}

EOF
fi

cat << EOF >> $MANIFEST
  # required element
  resourceProfile: ${CORE_RESOURCE_PROFILE:-"small"}

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

