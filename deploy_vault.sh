#!/usr/bin/env bash

. ./lib/k8s_functions.sh

# DESC: Store K8s certificates in a Secret
# ARGS: $1 (REQ): Cert dir
#       $2 (REQ): Application Name
# OUT: None
function store_k8s_certs() {
    if [[ $# -lt 2 ]]; then
        printf "\nERROR: Missing 2 args for store_k8s_certs()\n"
        exit -2
    fi

    if ! kubectl get secrets | grep ${2} > /dev/null 2>&1; then
        kubectl create secret generic ${2} \
          --from-file=${1}/ca.pem \
          --from-file=${1}/${2}.pem \
          --from-file=${1}/${2}-key.pem

        printf "... ${2} certs stored as a secret\n"
    else
        printf "... ${2} certs are already stored as a secret\n"
    fi

    # K8s Secrets sanity
    printf "Testing to see if the ${2} Secret is sane...\n"
    if ! kubectl describe secret ${2} > /dev/null 2>&1; then
        printf "ERROR: can't find the ${2} Secret!\n"
    else
        printf "${2} Secret looks good\n"
    fi
}


# DESC: Creates a k8s Desployment
# ARGS: $1 (REQ): Application Name
# OUT: None
function k8s_deployment() {
    if [[ $# -lt 1 ]]; then
        printf "\nERROR: Missing 1 arg for k8s_deployment()\n"
        exit -2
    fi

    if ! kubectl get pods | grep ${1} > /dev/null 2>&1; then
        kubectl apply -f ${1}/deployment.yaml
        printf "... ${1} Deployment applied\n"

        # Wait for pods to launch
        printf "... waiting for ${1} pods to launch\n"
        sleep 10

        POD=$(kubectl get pods -o=name | grep ${1} | sed "s/^.\{4\}//")
        while true; do
            STATUS=$(kubectl get pods ${POD} -o jsonpath="{.status.phase}")
            if [ "$STATUS" == "Running" ]; then
                break
            else
                printf "Pod status is: ${STATUS}\n"
                sleep 5
            fi
        done
    else
        printf "... ${1} Deployment was already applied\n"
    fi

    # K8s Deployment Sanity
    printf "Testing to see if the ${1} Deployment is sane...\n"
    if ! kubectl get pods | grep ${1} > /dev/null 2>&1; then
        printf "ERROR: can't find ${1} Pods!\n"
        exit 1
    else
        printf "${1} Pods look good\n"
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

    echo ""
    echo ""--- Forwarding port ${vault_port} for ${vault_pod} ---
    local vault_pod=$(kubectl get pods -o=name | grep vault | sed "s/^.\{4\}//")
    k8s_port_forwarding ${vault_pod} ${vault_port} ${vault_port}
}

main

