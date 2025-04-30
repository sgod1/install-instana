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
CORE_CONFIG_EMAIL_SMTP_ENABLE(optional) ... 
CORE_CONFIG_EMAIL_AWS_SES_ENABLE(optional) ... 
CORE_CONFIG_PROXY_ENABLE(optional) ... 
CORE_CONFIG_TOKEN_SECRET)(required) ... hidden
CORE_CONFIG_SP_KEY_PASSWORD(required) ... missing ... 
```

Set all `missing` required parameters and optional parameters that you need.<br/>


## Setting Instana version
Instana version information is defined in the `release.yaml` file which is updated when new instana versions are released and older versions purged.<br>

Run `show-version-combination.sh` script to view supported combinations<br/>
of instana plugin and instana versions.<br/>

```
show-version-combination.sh 
instana plugin: 1.3.0, instana: 293(3.293.425-0)
instana plugin: 1.2.1, instana: 287(3.287.582-0) 289(3.289.617-0)
instana plugin: 1.2.0, instana: 287(3.287.582-0) 289(3.289.617-0)
instana plugin: 1.1.1, instana: 281(3.281.446-0) 283(3.283.450-0) 285(3.285.627-0)
instana plugin: 1.1.0, instana: 281(3.281.446-0) 283(3.283.450-0)
instana plugin: 1.0.0, instana: 279(3.279.395-0)
```
Set `INSTANA_PLUGIN_VERSION` and `INSTANA_VERSION` values to one of supported versions in `instana.env` file.<br/>

```
INSTANA_PLUGIN_VERSION="1.3.0"
INSTANA_VERSION="293"
```

### Manifest customization and INSTANA_INSTALL_PROFILE
Component customization is defined by `*env.yaml` file specific to the component.<br/>

```
zookeeper-env.yaml - customize zookeeper
cassandra-env.yaml - customize cassandra
postgres-env.yaml - customize postgres
elasticsearch-env.yaml - customize elasticsearch
clickhouse-env.yaml - customize clickhouse
kafka-env.yaml - customize kafka
beeinstana-env.yaml - customize beeinstana
core-env.yaml - customize core
unit-env.yaml - customize unit
agent-env.yaml - customize isntana agent
```

All customizations are applied by passing env file to the `cr-*-env.sh` script.<vr/>

`cr-*-env.sh` will set environment variables required by the `*-env.yaml` file.<br/>

```
cr-zookeeper-env.sh - customize and generate zookeeper manifest in gen/zookeeper-${instana-version}.yaml
cr-cassandra-env.sh - customize and generate cassandra manifest in gen/cassandra-${instana-version}.yaml
cr-postgres-env.sh - customize and generate postgres manifest in gen/postgres-${instana-version}.yaml
cr-elasticsearch-env.sh - customize and generate elasticsearch manifest in gen/elasticsearch-${instana-version}.yaml
cr-clickhouse-env.sh - customize and generate clickhouse manifest in gen/clickhouse-${instana-version}.yaml
cr-kafka-env.sh - customize and generate kafka manifest in gen/kafka-${instana-version}.yaml
cr-beeinstana-env.sh - customize and generate beeinstana manifest in gen/beeinstana-${instana-version}.yaml
cr-core-env.sh - customize and generate core manifest in gen/core-${instana-version}.yaml
cr-unit-env.sh - customize and generate unit manifest in gen/unit-${instana-version}.yaml
```

### Instana install profile
`*env.yaml` customize cr template for a list of profiles.<br/>

Customization works by applying profile specific value to `yq` path in cr template.<br/>

If profile name is matched, then it's value is used, otherwise default value is used.<br/>

Here is example from `postgres-env.yaml`:<br/>

```
- name: postgres-memory-request
  path: .spec.resources.requests.memory
  values:
    default: 4Gi
    uat: 8Gi
    prod: 8Gi
```

`path` is `yq` path to an element in `postgres.yaml` cr template.<br/>
`values` lists values based on the install profile.<br/>

Profile names are arbitrary.<br/>

Set `INSTANA_INSTALL_PROFILE` value in `instana.env`:<br/>
```
INSTANA_INSTALL_PROFILE="uat"
```

### Public key pairs
Public/private key pairs are required by `instana-core` secret and `instana-tls` secret.<br/>

`tls-key-cert.sh` script creates private/public key pair and a csr.<br/>

csr is configured by the `tls-csr-env.yaml` file that defines cryptographic parameters and `dn` components for a list of instana install profiles.<br/>
If profile name is matched, then it's values are used, otherwise default values are used.<br/>

Do not include `CN` in the list of `dn` components.<br/>
`CN` is automatically set to the value of `BASE_DOMAIN`.<br/>

Customize `tls-csr-env.yaml` file:<br/>
```
env:
- name: csr-default-bits
  path: .csr.default-bits
  values:
    default: 4096

- name: csr-default-md
  path: .csr.default-md
  values:
    default: sha256

  # required dn components
  # do not include cn
- name: ingress-dn
  path: .csr.dn
  values:
    default:
      C: US
      ST: CA
      L: Los Angeles
      O: Instana
      OU: sre
      emailAddress: sre@instana.com
    uat:
      C: US
      ST: CA
      L: Los Angeles
      O: Instana
      OU: sre
      emailAddress: sre@instana.com
    prod:
      C: US
      ST: CA
      L: Los Angeles
      O: Instana
      OU: sre
      emailAddress: sre@instana.com
```

Generated alt names:</br>
```
DNS.1 = base.domain
DNS.2 = agent-acceptor.base.domain
DNS.3 = otlp-grpc.base.domain
DNS.4 = otlp-http.base.domain
DNS.5 = unit-tenant.base.domain
```

`tls-key-cert.sh` takes `qualifier`, `profile name` and `key password file` as input.</br>

Qualifier value is set by calling script to distingush output files: `sp` for `instana-core` and `ingress` for `instana-tls`.<br/>

csr is immediately signed by the internal ca.<br/>

It creates output files:<br/>
```
gen/tls/{qualifier}-conf.conf - csr config file
gen/tls/{qualifier}-csr.pem - csr file
gen/tls/{qualifier}-key.pem - private key file encrypted by the password from input password file
gen/tls/{qualifier}-cert.pem - public key cert singed by the root ca
gen/tls/{qualifier}-cert-chain.pem - public key cert chain singed by the root ca

gen/tls/{qualifier}-root-ca-key.pem - root ca private key
gen/tls/{qualifier}-root-ca-cert.pem - root ca cert.
```

### Certificates signed by external ca.

Create required crypto files by running `tls-key-cert-external.sh` script with the qualifier (sp|ingress) as an agrument.<br/>
```
tls-key-cert-external.sh ingress|sp
```

Submit `gen/tls/ingress-csr.pem` to an external ca.<br/>
```
tls-export-csr.sh ingress <export-csr-file-name>
```

Copy received certificate chain to `gen/tls/{qual}-cert-chain.pem` file<br/>

```
tls-import-cert-chain.sh <cert_chain_file> ingress|sp
```

Note: no checks are done at this time by the import script to validate external certificate.<br/>

Example:<br/>

```
tls-key-cert-external.sh ingress
tls-export-csr.sh ingress <export-csr-file-name>
tls-import-cert-chain.sh <cert-chain-file> ingress
```

### Custom ca bundle for instana-core
To import custom ca bundle for instana-core, run `core-import-ca-bundle.sh` and pass bundle path to the script<br/>
```
core-import-ca-bundle.sh bundle-file
```

### Private Registry and Instana Registry Proxy
Set `PRIVATE_DOCKER_SERVER` and optionally `PRIVATE_REGISTRY_SUBPATH` to push images into private repository.<br/>

Set `PRIVATE_REGISTRY_USER` and `PRIVATE_REGISTRY_PASSWORD` for authentication.<br/>

If you have image repository configured as a proxy for Instana image repository, set `INSTANA_REGISTRY_PROXY` to pull images into proxy repository.<br/>

Optionally, set `INSTANA_REGISTRY_PROXY_USER` and `INSTANA_REGISTRY_PROXY_PASSWORD` for proxy repository authentication.<br/>

## Steps 

### Install instana plugin and Instana license.
Install cli tools and download Instana license.<br/>
```
0-wget-cli-tools.sh
0-install-cli-tools.sh
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

### Generate image [and run] mirror scripts
```
1-generate-mirror-scripts.sh [run]
```
Mirror scripts are generated in `gen/mirror` subdirectory<br/>

To run `pull/tag/push` scripts automatically, pass `run` argument to the script.<br/>

#### Certificate Manager images.
Change to the `gen/mirror` directory.<br/>
```
cert-manager-pull-images.sh
cert-manager-tag-images.sh
cert-manager-push-images.sh
```
#### Datastore images.
Change to the `gen/mirror` directory.<br/>
```
datastore-pull-images.sh
datastore-tag-images.sh
datastore-push-images.sh
```
#### Backend images.
Change to the `gen/mirror` directory.<br/>
```
backend-pull-images.sh
backend-tag-images.sh
backend-push-images.sh
```

### Instana operator images
Change to the `gen/mirror` directory.<br/>
```
instana-operator-pull-images.sh
instana-operator-tag-images.sh
instana-operator-push-images.sh
```

### Manifests
Review and update component customization values in `*env.yaml` files based on `INSTANA_INSTALL_PROFILE`<br/>

Generate all manifests.<br/>
```
2-generate-manifests.sh
```
Manifests are generated in the `gen` directory.<br/>

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
Update `tls-csr-env.yaml` file with dn values.<br/>

Set service provider key password:<br/>

Update `instana.env` file:<br/>
```
CORE_CONFIG_SP_KEY_PASSWORD=password
```

Key pairs are created in gen/tls directory with the `sp` qualifier<br/>
for oidc service provider keychain, and 'ingress' qualifier for Instana ingress.<br/>

To use external root ca, follow `Certificates signed by external ca` section.<br/>

To add custom trust, import custom ca bundle:<br/>
```
core-import-ca-bundle.sh ca-bundle-path
```

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

### Instana Agent ###

#### Deploying Instana Agent with the yaml file ####

Yaml file is the simpliest way to deploy Instana agent.<br/>

We refer to 2 images, agent image and sensor image by the `latest` tag.<br/>

Agent image is modified (out of band) to inject custom jvm trust store.<br/>
Agent image tag is left to the agent image implementor.<br/>

```
agent_image="$PRIVATE_REGISTRY/instana/agent:latest"
agent_sensor_image="$PRIVATE_REGISTRY/instana/k8sensor:latest"
```

Agent file template is different for `k8s` platforms and `openshift`.<br/>

```
agent-template-k8s.yaml 
agent-template-ocp.yaml
```

Agent file is customized with the `agent-env.yaml` file.<br/>

Customization works the same way as with other components.<br/>

`yq` expression points to an element in the template we want to modify,<br/>
and `values` contain a list of profile specific values.<br/>

The only difference that profile name is agent deployment specific and is passed on the command line.<br/>

This is because you can deploy many agents to many clusters to many zones.<br/>

Generate agent file:<br/>
```
cr-agent.env ocp|k8s <cluster> <zone> [profile]
```

Output is written to the `gen` directory and agent file name is qualified by the cluster, zone and Instana version<br/>
```
updated agent manifest ./gen/instana-agent-<cluster>-<zone>-<instana-version>.yaml, profile default
```

### Deploying Instana Agent with the helm chart ###

With the helm chart we need to keep track of the chart version, operator version, and images.<br/>

Chart is customized with the `values` file.<br/>

```
helm repo add agent https://agents.instana.io/helm

helm repo list

NAME      URL                                                          
agent     https://agents.instana.io/helm
instana   https://helm.instana.io/artifactory/rel-helm-customer-virtual
```

```
helm search repo instana-agent

NAME                  CHART VERSION APP VERSION DESCRIPTION                 
agent/instana-agent   2.0.19        1.292.0     Instana Agent for Kubernetes
instana/instana-agent 2.0.19        1.292.0     Instana Agent for Kubernetes
```

It is recommended to work with the 'agent' helm repo.<br/>

Pull helm chart:<br/>
```
helm pull agent/instana-agent --version=2.0.19 -d gen/charts/293
```

Update `values` file in `install-agent-operator.sh` script.<br/>

Install agent helm chart:<br/>
```
./install-agent-operator.sh <cluster> <zone> [install|upgrade]
```
