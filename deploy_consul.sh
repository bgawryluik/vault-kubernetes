#!/usr/bin/env bash

# DESC: Generates Gossip Encryption Key
# ARGS: $1 (REQ): Cert dir
#       $2 (REQ): Application Name
# OUT: None
function gossip_encryption_key() {
    if [[ $# -lt 2 ]]; then
        printf "\nERROR: Missing 2 args for gossip_encryption_key()\n"
        exit -2
    fi

    if ! kubectl get secrets | grep ${2} > /dev/null 2>&1; then
        export GOSSIP_ENCRYPTION_KEY=$(consul keygen)

        kubectl create secret generic ${2} \
            --from-literal="gossip-encryption-key=${GOSSIP_ENCRYPTION_KEY}" \
            --from-file=${1}/ca.pem \
            --from-file=${1}/${2}.pem \
            --from-file=${1}/${2}-key.pem

        printf "... Gossip Encryption Key created\n"
    else
        printf "... Gossip Encryption Key was already created\n"
    fi

    # Gossip Encryption Key Sanity
    printf "Testing to see if the Gossip Encryption Key is sane...\n"
    if ! kubectl describe secret ${2} > /dev/null 2>&1; then
        printf "ERROR: can't find the Gossip Encryption Key!\n"
        exit 1
    else
        printf "Gossip Encryption Key looks good\n"
    fi
}


# DESC: Creates a k8s ConfigMap
# ARGS: $1 (REQ): Application Name
# OUT: None
function k8s_configmap() {
    if [[ $# -lt 1 ]]; then
        printf "\nERROR: Missing 1 arg for k8s_configmap()\n"
        exit -2
    fi

    if ! kubectl get configmaps | grep ${1} > /dev/null 2>&1; then
        kubectl create configmap ${1} --from-file=${1}/config.json
        printf "... ${1} ConfigMap created\n"
    else
        printf "... ${1} ConfigMap was already created\n"
    fi

    # K8s ConfigMap Sanity
    printf "Testing to see if the ${1} ConfigMap is sane...\n"
    if ! kubectl describe configmap ${1} > /dev/null 2>&1; then
        printf "ERROR: can't find the ${1} ConfigMap!\n"
        exit 1
    else
        printf "${1} ConfigMap looks good\n"
    fi
}


# DESC: Creates a k8s Service
# ARGS: $1 (REQ): Application Name
# OUT: None
function k8s_service() {
    if [[ $# -lt 1 ]]; then
        printf "\nERROR: Missing 1 arg for k8s_service()\n"
        exit -2
    fi

    if ! kubectl get service ${1} | grep ${1} > /dev/null 2>&1; then
        kubectl create -f ${1}/service.yaml
        printf "... ${1} Service created\n"
    else
        printf "... ${1} Service was already created\n"
    fi

    # K8s Service Sanity
    printf "Testing to see if the ${1} Service is sane...\n"
    if ! kubectl get service ${1} > /dev/null 2>&1; then
        printf "ERROR: can't find the ${1} Service!\n"
        exit 1
    else
        printf "${1} Service looks good\n"
    fi
}


# DESC: Creates a k8s StatefulSet
# ARGS: $1 (REQ): Application Name
# OUT: None
function k8s_statefulset() {
    if [[ $# -lt 1 ]]; then
        printf "\nERROR: Missing 1 arg for k8s_statefulset()\n"
        exit -2
    fi

    if ! kubectl get pods | grep ${1} > /dev/null 2>&1; then
        kubectl create -f ${1}/statefulset.yaml
        printf "... ${1} StatefulSet created\n"

        # Wait for pods to launch
        printf "... waiting for ${1} pods to launch\n"
        sleep 10
        POD=$(kubectl get pods -o=name | grep ${1}-0 | sed "s/^.\{4\}//")
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
        printf "... ${1} StatefulSet was already created\n"
    fi

    # K8s StatefulSet Sanity
    printf "Testing to see if the ${1} StatefulSet is sane...\n"
    if ! kubectl get pods | grep ${1} > /dev/null 2>&1; then
        printf "ERROR: can't find ${1} Pods!\n"
        exit 1
    else
        printf "${1} Pods look good\n"
    fi
}


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
    local app_name="consul"
    local consul_pod="consul-1"
    local consul_port=8500

    echo "--- Generate Gossip Encryption Key ---"
    gossip_encryption_key ${certs_dir} ${app_name}

    echo ""
    echo "--- Creating ${app_name} ConfigMap ---"
    k8s_configmap ${app_name}

    echo ""
    echo "--- Creating ${app_name} Service ---"
    k8s_service ${app_name}

    echo ""
    echo "--- Creating ${app_name} StatefulSet ---"
    k8s_statefulset ${app_name}

    echo "--- Forwarding port ${consul_port} for ${consul_pod} ---"
    k8s_port_forwarding ${consul_pod} ${consul_port} ${consul_port}
}

main

