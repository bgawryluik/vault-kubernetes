#!/usr/bin/env bash

. ./lib/functions.sh

# DESC: Generates Gossip Encryption Key
# ARGS: $1 (REQ): Cert dir
#       $2 (REQ): Application Name
#       $3 (OPT): Namespace
# OUT: None
function gossip_encryption_key() {
    # Validate args
    if [[ $# -lt 2 ]]; then
        error "ERROR: Missing 2 args for gossip_encryption_key()"
        exit -2
    fi

    # Set namespace
    if [ -z $3+x} ]; then
        local ns="default"
    else
        local ns="${3}"
    fi

    # Run K8s command
    if ! kubectl get secrets -n ${ns} | grep ${2} > /dev/null 2>&1; then
        export GOSSIP_ENCRYPTION_KEY=$(consul keygen)

        kubectl create secret generic ${2} -n ${ns} \
            --from-literal="gossip-encryption-key=${GOSSIP_ENCRYPTION_KEY}" \
            --from-file=${1}/ca.pem \
            --from-file=${1}/${2}.pem \
            --from-file=${1}/${2}-key.pem

        success "Gossip Encryption Key created"
    else
        info "Gossip Encryption Key was already created"
    fi

    # Check K8s command sanity
    info "Testing to see if the Gossip Encryption Key is sane"
    if ! kubectl describe secret ${2} -n ${ns} > /dev/null 2>&1; then
        substep_error "ERROR: can't find the Gossip Encryption Key!"
        exit 1
    else
        substep_info "Gossip Encryption Key looks good"
    fi
}


# DESC: MAIN PROCESSING
# ARGS: None
# OUT: None
function main() {
    local certs_dir="certs"
    local app_name="consul"
    local consul_pod="consul-1"
    local consul_port=8500
    local consul_ns="default"

    echo ""
    echo "--- Generate Gossip Encryption Key ---"
    gossip_encryption_key ${certs_dir} ${app_name} ${consul_ns}

    echo ""
    echo "--- Creating ${app_name} ConfigMap ---"
    k8s_configmap ${app_name} ${consul_ns}

    echo ""
    echo "--- Creating ${app_name} Service ---"
    k8s_service ${app_name} ${consul_ns}

    echo ""
    echo "--- Creating ${app_name} StatefulSet ---"
    k8s_statefulset ${app_name} ${consul_ns}

    echo ""
    echo "--- Forwarding port ${consul_port} for ${consul_pod} ---"
    k8s_port_forwarding ${consul_pod} ${consul_port} ${consul_port} ${consul_ns}
}

main

