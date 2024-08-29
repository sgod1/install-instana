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

### Install instana plugin and Instana license.
Install Instana plugin and download Instana license.<br/>
```
0-wget-instana-plugin.sh
download-instana-license.sh
```
Plugin and license are installed into `gen/bin` subdirectory.<br/>

### Generate image mirror scripts
```
1-generate-mirror-scripts.sh`<br/>
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

