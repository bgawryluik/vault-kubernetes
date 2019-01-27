#!/usr/bin/env bash

# DESC: MAIN PROCESSING
# ARGS: None
# OUT: None
function main() {
    local certs_dir="certs"
    local app_name="vault"
    local app_port=8200

    echo "--- Setting ${app_name} ENV Vars ---"
    export VAULT_ADDR=https://127.0.0.1:${app_port}
    export VAULT_CACERT="${certs_dir}/ca.pem"

    echo ""
    echo "--- Forwarding ${app_name} port: ${app_port} ---"
    POD=$(kubectl get pods -o=name | grep ${app_name} | sed "s/^.\{4\}//")
    kubectl port-forward $POD ${app_port}:${app_port}
}

main

