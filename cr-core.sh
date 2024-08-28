#!/bin/bash

source ../instana.env
source ./help-functions.sh

MANIFEST_HOME=$(get_manifest_home)

MANIFEST=$MANIFEST_HOME/$MANIFEST_FILENAME_CORE

echo writing core manifest to $MANIFEST

cat << EOF > $MANIFEST
apiVersion: instana.io/v1beta2
kind: Core
metadata:
  namespace: instana-core
  name: instana-core
spec:
  # The domain under which Instana is reachable
  baseDomain: $INSTANA_BASE_DOMAIN

  # Depending on your cluster setup, you may need to specify an image pull secret.
  imagePullSecrets:
    - name: instana-registry

  imageConfig:
    registry: $PRIVATE_REGISTRY

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

  #operationScopes:
  #- core
  #- global

  # This configures an SMTP server for sending e-mails.
  # Alternatively, Amazon SES is supported. Please see API reference for details.
  emailConfig:
    smtpConfig:
      from: smtp@example.com
      host: smtp.example.com
      port: 465
      useSSL: false
      startTLS: false

  agentAcceptorConfig:
    host: $INSTANA_AGENT_ACCEPTOR
    port: 443

  storageConfigs:
    rawSpans:

      #s3Config:
      #  # S3 Endpoint Ref: https://docs.aws.amazon.com/general/latest/gr/s3.html#s3_region
      #  endpoint:
      #  region:
      #  bucket:
      #  prefix:
      #  storageClass:
      #  bucketLongTerm:
      #  prefixLongTerm:
      #  storageClassLongTerm:

      pvcConfig:
        accessModes: 
          - ReadWriteMany
        resources:
          requests:
            storage: 100Gi
        storageClassName: $RWX_STORAGECLASS

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

  #serviceAccountAnnotations:
  #  eks.amazonaws.com/role-arn: arn:aws:iam::111122223333:role/my-role

  resourceProfile: $CORE_RESOURCE_PROFILE

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
