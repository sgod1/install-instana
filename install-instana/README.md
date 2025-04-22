# install-instana

This project is a fork of play-instana by Oleg Samoylov. 
It follows similar pattern of steps: install prerequisites, generate manifests and apply manifests.

It adds support for image mirror and fine-grained externalized component customization.<br/>

### Global Configuration Parameters
Base directory contains `instana-env-template.env` file that defines global configuration parameters required<br/>
for Instana instllation. This includes license keys, instana version, storage classes, admin user name and password, etc.<br/>

Copy `instana-env-template.env` to the `instana.env` file and update `instana.env` with your values.<br/>
```
cp instana-env-template.env instana.env
```

To see what parameters are required or optinal, run:<br/>
```
cd install-instana
./validate-instana-env.sh
```

```
-- install keys:
DOWNLOAD_KEY(required) ... missing ... 
SALES_KEY(required) ... missing ... 
AGENT_KEY(optional) ... 

-- install profile:
INSTANA_INSTALL_PROFILE(required) ... missing ... 

-- instana version:
INSTANA_PLUGIN_VERSION(required) ... missing ... 
INSTANA_VERSION(required) ... missing ... 

-- instana base domain:
INSTANA_UNIT_NAME(required) ... missing ... 
INSTANA_TENANT_NAME(required) ... missing ... 
INSTANA_BASE_DOMAIN(required) ... missing ... 
INSTANA_ADMIN_USER(required) = admin@instana.local
INSTANA_ADMIN_PASSWORD(required) ... missing ... 

-- instana cli:
PLATFORM(required) ... missing ... ocp|eks|gcp|k8s
KUBECTL(required) ... missing ... oc|kubectl
PODMAN(required) ... missing ... podman|docker
PODMAN_TLS_VERIFY(optional) ... list of options in instana.env

-- instana registry proxy:
INSTANA_REGISTRY_PROXY(optional) ... 
INSTANA_REGISTRY_PROXY_USER(optional) ... 
INSTANA_REGISTRY_PROXY_PASSWORD(optional) ... 

-- private registry:
PRIVATE_DOCKER_SERVER(required) ... missing ... 
PRIVATE_REGISTRY_SUBPATH(optional) ... 
PRIVATE_REGISTRY_USER(required) ... missing ... 
PRIVATE_REGISTRY_PASSWORD(required) ... missing ... 

-- storage classes:
RWO_STORAGECLASS(required) ... missing ... 
RWX_STORAGECLASS(required) ... missing ... 

-- namespace security label:
K8S_PSA_LABEL(optional) = privileged

-- datastore creds:
CLICKHOUSE_USER_PASS(required) ... hidden
CLICKHOUSE_ADMIN_PASS(required) ... hidden
BEEINSTANA_ADMIN_PASS(required) ... hidden

-- resource profile:
CORE_RESOURCE_PROFILE(required) ... missing ... 

-- core config:
CORE_CONFIG_RAW_SPANS_TYPE(required) = pvc
CORE_CONFIG_EMAIL_ENABLE_SMTP(optional) ... 
CORE_CONFIG_EMAIL_ENABLE_AWS_SES(optional) ... 
CORE_CONFIG_PROXY_ENABLE(optional) ... 
CORE_CONFIG_TOKEN_SECRET)(required) ... hidden
CORE_CONFIG_SP_KEY_PASSWORD(required) ... missing ... 
```

Set all `missing` required parameters and optional parameters that you need.<br/>


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
Run `show-version-combination.sh` script to view supported plugin/instana versions.<br/>
```
./show-version-combination.sh 
instana plugin: 1.0.0, instana: 279(3.279.395-0)
instana plugin: 1.1.0, instana: 281(3.281.446-0) 283(3.283.450-0)
instana plugin: 1.1.1, instana: 281(3.281.446-0) 283(3.283.450-0) 285(3.285.627-0)
instana plugin: 1.2.0, instana: 287(3.287.582-0)
```
Select new version combination and update `INSTANA_PLUGIN_VERSION` and `INSTANA_VERSION` values in `..\instana.env` file.<br/>
When upgrading versions follow Instana documentation on version sequence.<br/>

After versions are updated in the `../instana.env` file you need to download and install new instana plugin.<br/>
Run:<br/>
```
0-wget-instana-plugin.sh
0-install-kubectl-plugin.sh
```
Check that plugin/version combination agree with the installed plugin.<br/>
```
./check-version-config.sh 
instana plugin: 1.1.1, instana: 281(3.281.446-0) 283(3.283.450-0) 285(3.285.627-0)
release.env: compat check pass: plugin: 1.1.1, list: 281 283 285, instana: 283
instana semantic version: 3.283.450-0
kubectl-instana version 1.1.1 (commit=6e0290eeb35fb028c81da94fb88cda786e55f14b, date=2024-11-13T13:51:42Z, defaultInstanaVersion=3.283.457-0)
```

If you see mismatch between configured versions and plugin version, check that plugin version is downloaded<br/>
and run `0-install-kubectl-plugin.sh`.<br/>

Instana is upgraded to the versions reported by the `check-version-config.sh` script.<br/>

### Mirroring images
Generate image mirror scripts in the `gen/mirror/<instana-version>` directory.<br/>
```
1-generate-mirror-scripts.sh
```
Run `pull`, `tag`, and `push` scripts for backend, datastore, and cert-manager<br/>
as described in the `Generate image mirror` scripts section.<br/>

### Pulling helm charts
To pull helm charts, run:<br/>
```
3-pull-datastore-charts.sh
```
Charts are written to the `gen/charts/<instana-version>` directory.<br/>

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

### Upgrade Instana operator
Instana operator is managed with the instana plugin.<br/>
To upgrade instana operator directly, run:<br/>
```
install-instana-operator.sh
```
If you want to generate Instana operator yaml files and apply them,<br>
run `cr-instana-operator.sh` scirpt:<br/>
```
cr-instana-operator.sh
```
Output is written to the `gen/instana-operator-manifests/<plugin>-<instana>` directory.<br/>
Instana operator `values` file is written to the `gen/instana-operator-values.yaml`<br/>

Apply Instana operator CR files:<br/>
```
install-insana-operator-apply-cr.sh
```

### Upgrade Instana Backend
To upgrade Instana backend, run:<br/>
```
cr-core-patch.sh
install-core-apply-patch.sh
```

Watch `core` and `unit`.<br/>

### Upgrade cert manager
Cert manager version is defined in `certmgr-images.env`<br/>
To upgrade certmgr, run:<br/>
```
install-cert-manager.sh upgrade
```
