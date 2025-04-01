#!/bin/bash

if [[ -f ../instana.env ]]; then
   source ../instana.env
else
   echo instana.env file not found in the parent directory, required...
   exit 1
fi

rc=0

check_for_opt_key() {
  local key=$1
  local optval=$2

  val=${optval:-"optional"}

  check_for_key $key $val
}

check_for_key() {
  local key="$1"
  local val="$2"
  local status=""

  if test $val; then
    status="ok"
  else
    rc=1
    status="missing"
  fi

  if test "$status" = "missing"; then
    echo "   "$status ... $key 

  elif [[ $key =~ KEY ]]; then
    echo $key ... "hidden"

  elif [[ $key =~ PASS ]]; then
    echo $key ... "hidden"

  elif [[ $key =~ TOKEN ]]; then
    echo $key ... "hidden"

  else
    echo $key ... "$val"
  fi

}

function display_header() {
  local header=$@
  echo
  echo ${header}:
}

display_header "install keys"
check_for_key "DOWNLOAD_KEY" "$DOWNLOAD_KEY" 
check_for_key "SALES_KEY" "$SALES_KEY"

display_header "install profile"
check_for_key "INSTANA_INSTALL_PROFILE" "$INSTANA_INSTALL_PROFILE"

display_header "instana version"
check_for_key "INSTANA_PLUGIN_VERSION" "$INSTANA_PLUGIN_VERSION" 
check_for_key "INSTANA_VERSION" "$INSTANA_VERSION"

display_header "instana base domain"
check_for_key "INSTANA_UNIT_NAME" "$INSTANA_UNIT_NAME"
check_for_key "INSTANA_TENANT_NAME" "$INSTANA_TENANT_NAME"

check_for_key "INSTANA_BASE_DOMAIN" "$INSTANA_BASE_DOMAIN"

check_for_key "INSTANA_ADMIN_USER" "$INSTANA_ADMIN_USER"
check_for_key "INSTANA_ADMIN_PASSWORD" "$INSTANA_ADMIN_PASSWORD" 

display_header "instana cli"
check_for_key "PLATFORM" "$PLATFORM"
check_for_key "KUBECTL" "$KUBECTL"
check_for_key "PODMAN" "$PODMAN"
check_for_opt_key "PODMAN_TLS_VERIFY" "$PODMAN_TLS_VERIFY"
check_for_opt_key "PODMAN_HTTP_PROXY" "$PODMAN_HTTP_PROXY"
check_for_opt_key "PODMAN_HTTPS_PROXY" "$PODMAN_HTTPS_PROXY"

display_header "private registry"
check_for_key "PRIVATE_DOCKER_SERVER" "$PRIVATE_DOCKER_SERVER"
check_for_opt_key "PRIVATE_REGISTRY_SUBPATH" "$PRIVATE_REGISTRY_SUBPATH"
check_for_key "PRIVATE_REGISTRY_USER" "$PRIVATE_REGISTRY_USER"
check_for_key "PRIVATE_REGISTRY_PASSWORD" "$PRIVATE_REGISTRY_PASSWORD"

display_header "storage classes"
check_for_key "RWO_STORAGECLASS" "$RWO_STORAGECLASS"
check_for_key "RWX_STORAGECLASS" "$RWX_STORAGECLASS"

display_header "namespace security label"
check_for_opt_key "K8S_PSA_LABEL" "$K8S_PSA_LABEL"

display_header "datastore creds"
check_for_key "CLICKHOUSE_USER_PASS" "$CLICKHOUSE_USER_PASS"
check_for_key "CLICKHOUSE_ADMIN_PASS" "$CLICKHOUSE_ADMIN_PASS"
check_for_key "BEEINSTANA_ADMIN_PASS" "$BEEINSTANA_ADMIN_PASS"

display_header "resource profile"
check_for_key "CORE_RESOURCE_PROFILE" "$CORE_RESOURCE_PROFILE"

display_header "core config"
check_for_key "CORE_CONFIG_RAW_SPANS_TYPE" "$CORE_CONFIG_RAW_SPANS_TYPE"

check_for_opt_key "CORE_CONFIG_EMAIL_ENABLE_SMTP" "$CORE_CONFIG_EMAIL_ENABLE_SMTP"
if test "$CORE_CONFIG_EMAIL_ENABLE_SMTP"; then
check_for_key "CORE_CONFIG_EMAIL_SMTP_USER" "$CORE_CONFIG_EMAIL_SMTP_USER"
check_for_key "CORE_CONFIG_EMAIL_SMTP_PASSWORD" "$CORE_CONFIG_EMAIL_SMTP_PASSWORD"
fi

check_for_opt_key "CORE_CONFIG_EMAIL_ENABLE_AWS_SES" "$CORE_CONFIG_EMAIL_ENABLE_AWS_SES"
if test "$CORE_CONFIG_EMAIL_ENABLE_AWS_SES"; then
check_for_key "CORE_CONFIG_AWS_IAM_ACCESS_KEY_ID" "$CORE_CONFIG_AWS_IAM_ACCESS_KEY_ID"
check_for_key "CORE_CONFIG_AWS_IAM_SECRET_KEY" "$CORE_CONFIG_AWS_IAM_SECRET_KEY"
fi

#check_for_mutex_key k1 v1 k2 v2

check_for_opt_key "CORE_CONFIG_PROXY_ENABLE" "$CORE_CONFIG_PROXY_ENABLE"
if test "$CORE_CONFIG_PROXY_ENABLE"; then
check_for_key "CORE_CONFIG_PROXY_USER" "$CORE_CONFIG_PROXY_USER"
check_for_key "CORE_CONFIG_PROXY_PASSWORD" "$CORE_CONFIG_PROXY_PASSWORD"
fi

check_for_key "CORE_CONFIG_TOKEN_SECRET" "$CORE_CONFIG_TOKEN_SECRET"

check_for_key "CORE_CONFIG_SP_KEY_PASSWORD" "$CORE_CONFIG_SP_KEY_PASSWORD"


echo
if [ $rc -gt 0 ]; then echo "validation failed..."; else echo "validation passed..."; fi

exit $rc
