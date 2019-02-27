#!/usr/bin/env bash

. ./lib/functions.sh

# DESC: Checks if a binary exists in the search path
# ARGS: $1 (REQ): Name of the target binary
# OUT: None
function check_binary() {
    if [[ $# -lt 1 ]]; then
        error "ERROR: Missing arg for check_binary()"
        exit -2
    fi

    if ! command -v "${1}"; then
        error "ERROR: Can't find ${1} in your PATH"
        error "Please install ${1}"
        exit -1
    fi

    success "${1} is in your PATH"
}


# DESC: Ensure that docker is running (all platforms)
# ARGS: None
# OUT: None
function check_docker_running() {
    doc_running=$(curl -s --unix-socket /var/run/docker.sock http://ping > /dev/null)
    status=$?

    if [ "${status}" == "7" ]; then
        error "ERROR: The docker service is NOT running. Please start docker"
        exit -1
    fi

    success "docker service is running"
}


# DESC: Ensure that minikube is running
# ARGS: None
# OUT: None
function check_minikube_running() {
    if ! minikube status; then
        error "ERROR: minikube service is NOT running. Please start minikube"
        exit -1
    fi

    success "minikube is running"
}

# DESC: MAIN PROCESSING
# ARGS: None
# OUT: None
function main() {
    echo "--- Checking for required binaries ---"
    local deps=(
        "docker"
        "minikube"
        "kubectl"
        "consul"
        "vault"
        "go"
        "cfssl"
    )

    # check for required binaries
    for dep in "${deps[@]}"; do
        check_binary "${dep}"
    done

    echo ""
    echo "--- Checking for required services ---"
    check_docker_running
    check_minikube_running
}

main
