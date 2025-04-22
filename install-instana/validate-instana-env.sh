#!/bin/bash

if [[ -f ../instana.env ]]; then
   source ../instana.env
else
   echo instana.env file not found in the parent directory, required...
   exit 1
fi

# error count
rc=0

# missing value
missingval="_"

check_for_opt_key() {

  local key="$1"
  local val="$2"
  local expected="$3"

  display_key_val "optional" "$key" "$val" "$expected"
}

check_for_key() {
  local key="$1"
  local val="$2"
  local expected="$3"
  local status=""

  display_key_val "required" "$key" "$val" "$expected"
}

function display_key_val() {
  local keytype="$1" # required|optional
  local key="$2"
  local val="$3"
  local expected="$4"

  if [[ $val == $missingval ]]; then

    if [[ $keytype == "required" ]]; then
      rc=1
      echo -e "$key($keytype) ... \033[0;31mmissing\033[0m ... ${expected}"

    elif [[ $keytype == "optional" ]]; then
      echo "$key($keytype) ... ${expected}"

    else
      echo "unexpected key type: $key, $keytype"

    fi

  elif [[ $key =~ KEY ]]; then
    echo "$key($keytype) ... hidden"

  elif [[ $key =~ PASS ]]; then
    echo "$key($keytype) ... hidden"

  elif [[ $key =~ TOKEN ]]; then
    echo "$key)($keytype) ... hidden"

  else
    echo "$key($keytype) = $val"
  fi

}

function display_header() {
  local header="-- $@"
  echo
  echo ${header}:
}

#
# main
#

display_header "install keys"
check_for_key "DOWNLOAD_KEY" "${DOWNLOAD_KEY:-$missingval}" 
check_for_key "SALES_KEY" "${SALES_KEY:-$missingval}"
check_for_opt_key "AGENT_KEY" "${AGENT_KEY:-$missingval}"

display_header "install profile"
check_for_key "INSTANA_INSTALL_PROFILE" "${INSTANA_INSTALL_PROFILE:-$missingval}"

display_header "instana version"
check_for_key "INSTANA_PLUGIN_VERSION" "${INSTANA_PLUGIN_VERSION:-$missingval}" 
check_for_key "INSTANA_VERSION" "${INSTANA_VERSION:-$missingval}"

display_header "instana base domain"
check_for_key "INSTANA_UNIT_NAME" "${INSTANA_UNIT_NAME:-$missingval}"
check_for_key "INSTANA_TENANT_NAME" "${INSTANA_TENANT_NAME:-$missingval}"

check_for_key "INSTANA_BASE_DOMAIN" "${INSTANA_BASE_DOMAIN:-$missingval}"

check_for_key "INSTANA_ADMIN_USER" "${INSTANA_ADMIN_USER:-$missingval}"
check_for_key "INSTANA_ADMIN_PASSWORD" "${INSTANA_ADMIN_PASSWORD:-$missingval}" 

display_header "instana cli"
check_for_key "PLATFORM" "${PLATFORM:-$missingval}" "ocp|eks|gcp|k8s"
check_for_key "KUBECTL" "${KUBECTL:-$missingval}" "oc|kubectl"
check_for_key "PODMAN" "${PODMAN:-$missingval}" "podman|docker"
check_for_opt_key "PODMAN_TLS_VERIFY" "${PODMAN_TLS_VERIFY:-$missingval}" "list of options in instana.env"

display_header "instana registry proxy"
check_for_opt_key "INSTANA_REGISTRY_PROXY" "${INSTANA_REGISTRY_PROXY:-$missingval}"
check_for_opt_key "INSTANA_REGISTRY_PROXY_USER" "${INSTANA_REGISTRY_PROXY_USER:-$missingval}"
check_for_opt_key "INSTANA_REGISTRY_PROXY_PASSWORD" "${INSTANA_REGISTRY_PROXY_PASSWORD:=$missingval}"

display_header "private registry"
check_for_key "PRIVATE_DOCKER_SERVER" "${PRIVATE_DOCKER_SERVER:-$missingval}"
check_for_opt_key "PRIVATE_REGISTRY_SUBPATH" "${PRIVATE_REGISTRY_SUBPATH:-$missingval}"
check_for_key "PRIVATE_REGISTRY_USER" "${PRIVATE_REGISTRY_USER:-$missingval}"
check_for_key "PRIVATE_REGISTRY_PASSWORD" "${PRIVATE_REGISTRY_PASSWORD:-$missingval}"

display_header "storage classes"
check_for_key "RWO_STORAGECLASS" "${RWO_STORAGECLASS:-$missingval}"
check_for_key "RWX_STORAGECLASS" "${RWX_STORAGECLASS:-$missingval}"

display_header "namespace security label"
check_for_opt_key "K8S_PSA_LABEL" "${K8S_PSA_LABEL:-$missingval}"

display_header "datastore creds"
check_for_key "CLICKHOUSE_USER_PASS" "${CLICKHOUSE_USER_PASS:-$missingval}"
check_for_key "CLICKHOUSE_ADMIN_PASS" "${CLICKHOUSE_ADMIN_PASS:-$missingval}"
check_for_key "BEEINSTANA_ADMIN_PASS" "${BEEINSTANA_ADMIN_PASS:-$missingval}"

display_header "resource profile"
check_for_key "CORE_RESOURCE_PROFILE" "${CORE_RESOURCE_PROFILE:-$missingval}"

display_header "core config"
check_for_key "CORE_CONFIG_RAW_SPANS_TYPE" "${CORE_CONFIG_RAW_SPANS_TYPE:-$missingval}"

check_for_opt_key "CORE_CONFIG_EMAIL_ENABLE_SMTP" "${CORE_CONFIG_EMAIL_ENABLE_SMTP:-$missingval}"
if test "$CORE_CONFIG_EMAIL_ENABLE_SMTP"; then
check_for_key "CORE_CONFIG_EMAIL_SMTP_USER" "{$CORE_CONFIG_EMAIL_SMTP_USER:-$missingval}"
check_for_key "CORE_CONFIG_EMAIL_SMTP_PASSWORD" "${CORE_CONFIG_EMAIL_SMTP_PASSWORD:-$missingval}"
fi

check_for_opt_key "CORE_CONFIG_EMAIL_ENABLE_AWS_SES" "${CORE_CONFIG_EMAIL_ENABLE_AWS_SES:-$missingval}"
if test "$CORE_CONFIG_EMAIL_ENABLE_AWS_SES"; then
check_for_key "CORE_CONFIG_AWS_IAM_ACCESS_KEY_ID" "${CORE_CONFIG_AWS_IAM_ACCESS_KEY_ID:-$missingval}"
check_for_key "CORE_CONFIG_AWS_IAM_SECRET_KEY" "${CORE_CONFIG_AWS_IAM_SECRET_KEY:-$missingval}"
fi

#check_for_mutex_key k1 v1 k2 v2

check_for_opt_key "CORE_CONFIG_PROXY_ENABLE" "${CORE_CONFIG_PROXY_ENABLE:-$missingval}"
if test "$CORE_CONFIG_PROXY_ENABLE"; then
check_for_key "CORE_CONFIG_PROXY_USER" "${CORE_CONFIG_PROXY_USER:-$missingval}"
check_for_key "CORE_CONFIG_PROXY_PASSWORD" "${CORE_CONFIG_PROXY_PASSWORD:-$missingval}"
fi

check_for_key "CORE_CONFIG_TOKEN_SECRET" "${CORE_CONFIG_TOKEN_SECRET:-$missingval}"

check_for_key "CORE_CONFIG_SP_KEY_PASSWORD" "${CORE_CONFIG_SP_KEY_PASSWORD:-$missingval}"

echo
if [ $rc -gt 0 ]; then echo "validation failed..."; else echo "validation passed..."; fi

exit $rc
