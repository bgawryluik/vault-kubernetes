#!/usr/bin/env bash

. ./lib/functions.sh


# DESC: Purges specified Helm deployment
# ARGS: $1 (REQ): Deployment name
# OUT: NONE
function helm_deployment_purge() {
    # Validate args
    if [[ $# -lt 1 ]]; then
        error "ERROR: Missing arg for helm_deployment_purge()"
        exit -2
    fi

    # Run Helm command
    if helm ls --all | grep ${1} > /dev/null 2>&1; then
        helm del --purge ${1}
        success "Deleted Helm deployment: ${1}"
    else
        info "Helm deployment: ${1} was already deleted"
    fi
}


# DESC: MAIN PROCESSING
# ARGS: None
# OUT: None
function main() {
    local certs_dir="certs"
    local vault_app_name="vault"
    local vault_ns="default"
    local consul_app_name="consul"
    local consul_ns="default"
    local monitoring_name="minikube"
    local monitoring_ns="monitoring"

    local crds=(
        "prometheuses.monitoring.coreos.com"
        "prometheusrules.monitoring.coreos.com"
        "servicemonitors.monitoring.coreos.com"
        "alertmanagers.monitoring.coreos.com"
    )

    echo ""
    echo "--- Halting port-forwarding ---"
    pkill kubectl

    echo ""
    echo "--- Deleting Vault Deployment ---"
    k8s_deployment_delete ${vault_app_name} ${vault_ns}

    echo ""
    echo "--- Deleting Vault Service ---"
    k8s_service_delete ${vault_app_name} ${vault_ns}

    echo ""
    echo "--- Deleting Vault ConfigMap ---"
    k8s_configmap_delete ${vault_app_name} ${vault_ns}

    echo ""
    echo "--- Deleting Consul StatefulSet ---"
    k8s_statefulset_delete ${consul_app_name} ${consul_ns}

    echo ""
    echo "--- Deleting Consul Service ---"
    k8s_service_delete ${consul_app_name} ${consul_ns}

    echo ""
    echo "--- Deleting Consul ConfigMap ---"
    k8s_configmap_delete ${consul_app_name} ${consul_ns}

    echo ""
    echo "--- Deleting Consul PersistentVolumeClaims ---"
    k8s_pvc_delete ${consul_app_name} ${consul_ns}

    echo ""
    echo "--- Deleting Helm deployment for monitoring ---"
    helm_deployment_purge ${monitoring_name}

    echo ""
    echo "--- Deleting Helm deployment for monitoring CRDs ---"
    for crd in "${crds[@]}"; do
        k8s_crd_delete ${crd}
    done

    echo ""
    echo "--- Delete monitoring Namespace ---"
    k8s_namespace_delete ${monitoring_ns}

    echo ""
    echo "--- Deleting Secrets ---"
    for secret in ${vault_app_name} ${consul_app_name}; do
        k8s_secret_delete ${secret}
    done

    if [ -d ${certs_dir} ]; then
        echo ""
        echo "--- Deleting certificates ---"
        rm -rfv ${certs_dir}
    fi
}

main

