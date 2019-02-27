#!/usr/bin/env bash

. ./lib/functions.sh


# DESC: MAIN PROCESSING
# ARGS: None
# OUT: None
function main() {
    local certs_dir="certs"
    local vault_app_name="vault"
    local consul_app_name="consul"

    echo "--- Halting port-forwarding ---"
    pkill kubectl

    echo ""
    echo "--- Deleting Vault Deployment ---"
    k8s_deployment_delete ${vault_app_name}

    echo ""
    echo "--- Deleting Vault Service ---"
    k8s_service_delete ${vault_app_name}

    echo ""
    echo "--- Deleting Vault ConfigMap ---"
    k8s_configmap_delete ${vault_app_name}

    echo ""
    echo "--- Deleting Consul StatefulSet ---"
    k8s_statefulset_delete ${consul_app_name}

    echo ""
    echo "--- Deleting Consul Service ---"
    k8s_service_delete ${consul_app_name}

    echo ""
    echo "--- Deleting Consul ConfigMap ---"
    k8s_configmap_delete ${consul_app_name}

    echo ""
    echo "--- Deleting Consul PersistentVolumeClaims ---"
    k8s_pvc_delete ${consul_app_name}

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
