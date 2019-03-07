#!/usr/bin/env bash

. ./lib/functions.sh

# DESC: Store K8s certificates in a Secret
# ARGS: $1 (REQ): Cert dir
#       $2 (REQ): Application Name
# OUT: None
function store_k8s_certs() {
    if [[ $# -lt 2 ]]; then
        error "ERROR: Missing 2 args for store_k8s_certs()"
        exit -2
    fi

    if ! kubectl get secrets | grep ${2} > /dev/null 2>&1; then
        kubectl create secret generic ${2} \
          --from-file=${1}/ca.pem \
          --from-file=${1}/${2}.pem \
          --from-file=${1}/${2}-key.pem

        success "${2} certs stored as a secret"
    else
        info "${2} certs are already stored as a secret"
    fi

    # K8s Secrets sanity
    info "Testing to see if the ${2} Secret is sane"
    if ! kubectl describe secret ${2} > /dev/null 2>&1; then
        substep_error "ERROR: can't find the ${2} Secret!"
        exit 1
    else
        substep_info "${2} Secret looks good"
    fi
}


# DESC: MAIN PROCESSING
# ARGS: None
# OUT: None
function main() {
    local certs_dir="certs"
    local app_name="vault"
    local vault_port=8200

    echo "--- Storing ${app_name} certs in a Secret ---"
    store_k8s_certs ${certs_dir} ${app_name}

    echo ""
    echo "--- Creating ${app_name} ConfigMap ---"
    k8s_configmap ${app_name}

    echo ""
    echo "--- Creating ${app_name} Service ---"
    k8s_service ${app_name}

    echo ""
    echo "--- Creating ${app_name} Deployment ---"
    k8s_deployment ${app_name}

    local vault_pod=$(kubectl get pods -o=name | grep vault | sed "s/^.\{4\}//")
    echo ""
    echo ""--- Forwarding port ${vault_port} for ${vault_pod} ---
    k8s_port_forwarding ${vault_pod} ${vault_port} ${vault_port}
}

main
