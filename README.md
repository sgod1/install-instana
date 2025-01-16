# install-instana

This project is a fork of play-instana by Oleg Samoylov. 
It follows similar pattern of steps: install prerequisites, generate manifests and apply manifests.

It adds support for image mirror and makes it easy to deploy components one at a time.

## Steps 

Copy `instana-env-template.env` file to the parent directory as `instana.env`:<br/>
```
cp instana-env-template.env ../instana.env
```
Update `../instana.env` file with your values.<br/>

Run `show-version-combination.sh` script to view supported combinations<br/>
of instana plugin and instana versions.<br/>
```
show-version-combination.sh 
instana plugin: 1.0.0, instana: 279(3.279.395-0)
instana plugin: 1.1.0, instana: 281(3.281.446-0) 283(3.283.450-0)
instana plugin: 1.1.1, instana: 281(3.281.446-0) 283(3.283.450-0) 285(3.285.627-0)
instana plugin: 1.2.0, instana: 287(3.287.582-0)
```
Set `INSTANA_PLUGIN_VERSION` and `INSTANA_VERSION` values to one of supported versions.<br/>

### Install instana plugin and Instana license.
Install Instana plugin and download Instana license.<br/>
```
0-wget-instana-plugin.sh
0-install-instana-plugin.sh
download-instana-license.sh
```
Plugin and license are installed into `gen/bin` subdirectory.<br/>

Check that plugin and instana version values agree with the installed plugin.<br/>
Run `check-version-config.sh` script.<br/>
```
./check-version-config.sh 
instana plugin: 1.1.1, instana: 281(3.281.446-0) 283(3.283.450-0) 285(3.285.627-0)
release.env: compat check pass: plugin: 1.1.1, list: 281 283 285, instana: 283
instana semantic version: 3.283.450-0
kubectl-instana version 1.1.1 (commit=6e0290eeb35fb028c81da94fb88cda786e55f14b, date=2024-11-13T13:51:42Z, defaultInstanaVersion=3.283.457-0)
```
This version check becomes important at upgrade time when plugin version and instana version are changed.<br/>
If you see mismatch, run `0-install-plugin.sh` script.<br/>

### Generate image mirror scripts
```
1-generate-mirror-scripts.sh
```
Mirror scripts are generated in `gen/mirror` subdirectory<br/>

#### Certificate Manager images.
Change to `gen/mirror` directory.<br/>
```
cert-manager-pull-images.sh
cert-manager-tag-images.sh
cert-manager-push-images.sh
```
#### Datastore images.
Change to `gen/mirror` directory.<br/>
```
datastore-pull-images.sh
datastore-tag-images.sh
datastore-push-images.sh
```
#### Backend images.
Change to `gen/mirror` directory.<br/>
```
backend-pull-images.sh
backend-tag-images.sh
backend-push-images.sh
```

### Manifests
Generate all manifests.<br/>
```
2-generate-manifests.sh
```
Manifests are generated in `gen` directory.<br/>

### Datastore operator charts
```
3-pull-datastore-charts.sh
```
Charts are installed in `gen/charts` directory<br/>

### Certificate Manager
Install Certificate Manager.<br/>
```
install-cert-manager.sh
```
### Datastores.
Install 3rd party datastore operator charts and apply custom resources.<br/>

#### Initialize Namespaces.
```
init-namespaces.sh
````

#### Zookeeper.
Install Zookeeper operator chart.<br/>
```
install-zookeeper-operator.sh
```
Appy Zookeeper custom resource.<br/>
```
install-zookeeper-apply-cr.sh
```
#### Kafka.
Install Kafka operator chart.<br/>
```
install-kafka-operator.sh
```
Appy Zookeeper custom resource.<br/>
```
install-kafka-apply-cr.sh
```
#### Elasticsearch.
Install Elasticsearch operator chart.<br/>
```
install-elasticsearch-operator.sh
```
Appy elasticsearch custom resource.<br/>
```
install-elasticsearch-apply-cr.sh
```
#### Postgres.
Install postgres operator chart.<br/>
```
install-postrges-operator.sh
```
Appy postgres custom resource.<br/>
```
install-postgres-apply-cr.sh
```
#### Cassandra.
Install cassandra operator chart.<br/>
```
install-cassandra-operator.sh
```
Appy cassandra custom resource.<br/>
```
install-cassandra-apply-cr.sh
```
#### Clickhouse.
Install clickhouse operator chart.<br/>
```
install-clickhouse-operator.sh
```
Appy clickhouse custom resource.<br/>
```
install-clickhouse-apply-cr.sh
```
#### Beeinstana.
Install beeinstana operator chart.<br/>
```
install-beeinstana-operator.sh
```
Appy beeinstana custom resource.<br/>
```
install-beeinstana-apply-cr.sh
```

### Instana Backend.

#### Instana Operator.
Install Instana operator.<br/>
```
./install-instana-operator.sh
```
#### Instana Core.
Apply Instana Core custom resource.<br/>
```
install-core-apply-cr.sh
```
#### Instana Unit.
Apply Instana Unit custom resource.<br/>
```
install-unit-apply-cr.sh
```

## Instana upgrade.
Instana is upgraded to the versions reported by the `check-version-config.sh` script.<br/>
```
./check-version-config.sh 
instana plugin: 1.1.1, instana: 281(3.281.446-0) 283(3.283.450-0) 285(3.285.627-0)
release.env: compat check pass: plugin: 1.1.1, list: 281 283 285, instana: 283
instana semantic version: 3.283.450-0
kubectl-instana version 1.1.1 (commit=6e0290eeb35fb028c81da94fb88cda786e55f14b, date=2024-11-13T13:51:42Z, defaultInstanaVersion=3.283.457-0)
```

### Patching datastore helm charts
To upgrade `zookeeper` operator helm chart:<br/>
```
install-zookeeper-operator.sh upgrade
```

To patch zookeeper cr:<br/>
```
cr-zookeeper-patch.sh replace
install-zookeeper-apply-patch.sh
```

To upgrade `kafka` operator helm chart:<br/>
```
install-kafka-operator.sh upgrade
```

To patch kafka cr:<br/>
```
cr-kafka-patch.sh replace
install-kafka-apply-patch.sh
```

To upgrade `elasticsearch` operator helm chart:<br/>
```
install-elasticsearch-operator.sh upgrade
```

To patch elasticsearch cr:<br/>
```
cr-elasticsearch-patch.sh replace
install-elasticsearch-apply-patch.sh
```

To upgrade `postgres` operator helm chart:<br/>
```
install-postgres-operator.sh upgrade
```

To patch postgres cr:<br/>
```
cr-postgres-patch.sh replace
install-postgres-apply-patch.sh
```
