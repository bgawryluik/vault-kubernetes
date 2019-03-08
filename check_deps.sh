#!/usr/bin/env bash

. ./lib/functions.sh

# DESC: Checks if a binary exists in the search path
# ARGS: $1 (REQ): Name of the target binary
# OUT: None
function check_binary() {
    # Validate args
    if [[ $# -lt 1 ]]; then
        error "ERROR: Missing arg for check_binary()"
        exit -2
    fi

    # Run commands
    if ! command -v "${1}"; then
        error "ERROR: Can't find ${1} in your PATH"
        error "Please install ${1}"
        exit -1
    fi

    info "${1} is in your PATH"
}


# DESC: Ensure that docker is running (Not sure if it works on Windows)
# ARGS: None
# OUT: None
function check_docker_running() {
    # From https://gist.github.com/peterver/ca2d60abc015d334e1054302265b27d9
    docker_ping=$(curl -s --unix-socket /var/run/docker.sock http://ping > /dev/null)
    STATUS=$?

    if [ "${STATUS}" == "7" ]; then
        error "ERROR: The docker service is NOT running. Please start docker"
        exit -1
    fi

    info "docker service is running"
}


# DESC: Ensure that minikube is running
# ARGS: None
# OUT: None
function check_minikube_running() {
    if ! minikube status > /dev/null 2>&1; then
        error "ERROR: minikube service is NOT running. Please start minikube"
        exit -1
    fi

    info "minikube is running"
}


# DESC: Ensure that helm is installed and running in minikube
# ARGS: NONE
# OUT: None
function initialize_helm() {
    local ns="kube-system"

    if ! kubectl get pods -n ${ns} | grep tiller > /dev/null 2>&1; then
        substep_info "...this may take a few moments"
        helm init --wait > /dev/null 2>&1
        success "Helm has been installed on minikube"
    else
        info "Helm is already installed on minikube"
    fi
}


# DESC: MAIN PROCESSING
# ARGS: None
# OUT: None
function main() {
    echo ""
    echo "--- Checking for required binaries ---"
    local deps=(
        "docker"
        "minikube"
        "kubectl"
        "helm"
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

    echo ""
    echo "--- Checking for Helm initialization ---"
    initialize_helm
}

main
