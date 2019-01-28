#!/usr/bin/env bash

# DESC: Perform port-forwarding in the background
# ARGS: #{1} (REQ): pod name
#       ${2} (REQ): local port
#       ${3} (REQ): pod port
# OUT: None
function k8s_port_forwarding() {
    if [[ $# -lt 3 ]]; then
        printf "\nERROR: Missing 3 args for k8s_port_forwarding()\n"
        exit -2
    fi

    if ! ps aux | grep "[k]ubectl port-forward" | grep ${1} > /dev/null 2>&1; then
        kubectl port-forward ${1} ${2}:${3} &
        printf "... ${1}: forwarding local port ${2} to pod port ${3}\n"
    else
        printf "... ${1}: already forwarding local port ${2} to pod port ${3}\n"
    fi

    # K8s Port-Forwarding Sanity
    printf "Testing to see if ${1}: forwarding pod port ${3} is sane...\n"
    if ! ps aux | grep "[k]ubectl port-forward" | grep ${1} | grep ${2} > /dev/null 2>&1; then
        printf "ERROR: Not Port-Forwarding ${1}: pod port ${3}!\n"
    else
        printf "Port-Forwarding ${1}: pod port ${3} looks good\n"
    fi
}


# DESC: MAIN PROCESSING
# ARGS: None
# OUT: None
function main() {
    local certs_dir="certs"
    local consul_pod="consul-1"
    local consul_port=8500
    local vault_pod=$(kubectl get pods -o=name | grep vault | sed "s/^.\{4\}//")
    local vault_port=8200

    echo "--- Forwarding port ${consul_port} for ${consul_pod} ---"
    k8s_port_forwarding ${consul_pod} ${consul_port} ${consul_port}

    echo ""
    echo "--- Setting up vault ENV Vars ---"
    export VAULT_ADDR=https://127.0.0.1:${vault_port}
    export VAULT_CACERT="${certs_dir}/ca.pem"
    echo "VAULT_ADDR=${VAULT_ADDR}"
    echo "VAULT_CACERT=${VAULT_CACERT}"

    echo ""
    echo ""--- Forwarding port ${vault_port} for ${vault_pod} ---
    k8s_port_forwarding ${vault_pod} ${vault_port} ${vault_port}
}

main

