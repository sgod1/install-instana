#!/bin/bash

source ../instana.env
source ./help-functions.sh

OUT_DIR=$(get_make_manifest_home)

echo writing clickhouse to $OUT_DIR/$MANIFEST_FILENAME_CLICKHOUSE

cat << EOF > $OUT_DIR/$MANIFEST_FILENAME_CLICKHOUSE
apiVersion: "clickhouse.altinity.com/v1"
kind: "ClickHouseInstallation"
metadata:
  name: "instana"
  namespace: "instana-clickhouse"

spec:
  defaults:
    templates:
      dataVolumeClaimTemplate: instana-clickhouse-data-volume
      logVolumeClaimTemplate: instana-clickhouse-log-volume
      serviceTemplate: service-template

  configuration:
    clusters:
      - name: local

        templates:
          podTemplate: clickhouse

        layout:
          shardsCount: 1
          replicasCount: 2

        schemaPolicy:
          replica: None
          shard: None

    files:
      config.d/storage.xml: |
        <clickhouse>
          <storage_configuration>
            <disks>
              <default/>
              <cold_disk>
                <path>/var/lib/clickhouse-cold/</path>
              </cold_disk>
            </disks>
            <policies>
              <logs_policy>
                <volumes>
                  <data>
                    <disk>default</disk>
                  </data>
                  <cold>
                    <disk>cold_disk</disk>
                  </cold>
                </volumes>
              </logs_policy>
              <logs_policy_v4>
                <volumes>
                  <tier1>
                    <disk>default</disk>
                  </tier1>
                  <tier2>
                    <disk>cold_disk</disk>
                  </tier2>
                </volumes>
              </logs_policy_v4>
            </policies>
          </storage_configuration>
        </clickhouse>

    profiles:
     default/max_memory_usage: 10000000000 # If memory limits are set, this value must be adjusted according to the limits.
     default/joined_subquery_requires_alias: 0
     default/max_execution_time: 100
     default/max_query_size: 1048576
     default/use_uncompressed_cache: 0
     default/enable_http_compression: 1
     default/load_balancing: random
     default/background_pool_size: 32
     default/background_schedule_pool_size: 32
     default/distributed_directory_monitor_split_batch_on_failure: 1
     default/distributed_directory_monitor_batch_inserts: 1
     default/insert_distributed_sync: 1
     default/log_queries: 1
     default/log_query_views: 1
     default/max_threads: 16
     default/allow_experimental_database_replicated: 1

    quotas:
     default/interval/duration: 3600
     default/interval/queries: 0
     default/interval/errors: 0
     default/interval/result_rows: 0
     default/interval/read_rows: 0
     default/interval/execution_time: 0

    settings:
     remote_servers/all-sharded/secret: clickhouse-default-pass
     remote_servers/all-replicated/secret: clickhouse-default-pass
     remote_servers/local/secret: clickhouse-default-pass
     max_concurrent_queries: 200
     max_table_size_to_drop: 0
     max_partition_size_to_drop: 0

    users:
      $CLICKOUSE_DEFAUL/password: "$CLICKHOUSE_DEFAULT_PASS"
      $CLICKHOUSE_USER/networks/ip: "::/0"
      $CLICKHOUSE_USER/password: "$CLICKHOUSE_USER_PASS"

    zookeeper:
      nodes:
      - host: instana-zookeeper-headless.instana-clickhouse

  templates:
    podTemplates:
    - name: clickhouse
      spec:
        containers:

        - name: instana-clickhouse
          image: docker.szesto.io/clickhouse-openssl:23.8.9.54-1-lts-ibm
          imagePullPolicy: IfNotPresent
          command:
          - clickhouse-server
          - --config-file=/etc/clickhouse-server/config.xml
          resources:
            requests:
              cpu: 1500m
              memory: 4Gi
          volumeMounts:
          - name: instana-clickhouse-cold-volume
            mountPath: /var/lib/clickhouse-cold/

        - name: clickhouse-log
          image: docker.szesto.io/clickhouse-openssl:23.8.9.54-1-lts-ibm
          imagePullPolicy: IfNotPresent
          command:
          - /bin/sh
          - -c
          - --
          args:
          - while true; do sleep 30; done;

        imagePullSecrets:
        - name: instana-registry

        securityContext:
          fsGroup: 0
          runAsGroup: 0
          runAsUser: 1001

    volumeClaimTemplates:
      - name: instana-clickhouse-data-volume
        reclaimPolicy: Retain
        spec:
          accessModes:
            - ReadWriteOnce
          resources:
            requests:
              storage: 1Gi
          storageClassName: ocs-storagecluster-ceph-rbd

      - name: instana-clickhouse-cold-volume
        reclaimPolicy: Retain
        spec:
          accessModes:
            - ReadWriteOnce
          resources:
            requests:
              storage: 1Gi
          storageClassName: ocs-storagecluster-ceph-rbd

      - name: instana-clickhouse-log-volume
        reclaimPolicy: Retain
        spec:
          accessModes:
            - ReadWriteOnce
          resources:
            requests:
              storage: 1Gi
          storageClassName: ocs-storagecluster-ceph-rbd

    serviceTemplates:
    - name: service-template
      spec:
        ports:
        - name: http
          port: 8123
        - name: tcp
          port: 9000
EOF
