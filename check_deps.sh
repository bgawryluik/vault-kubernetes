#!/usr/bin/env bash

# DESC: Checks if a binary exists in the search path
# ARGS: $1 (REQ): Name of the target binary
# OUT: None
function check_binary() {
    if [[ $# -lt 1 ]]; then
        printf "\nERROR: Missing arg for check_binary()\n"
        exit -2
    fi 

    if ! command -v "$1" > /dev/null 2>&1; then
        printf "\nERROR: Can't find $1 in your PATH.\n"
        printf "Please install $1.\n"
        exit -1
    fi

    printf "... $1 is in your PATH\n"
}


# DESC: Ensure that docker is running (all platforms)
# ARGS: None
# OUT: None
function check_docker_running() {
    doc_running=$(curl -s --unix-socket /var/run/docker.sock http://ping > /dev/null)
    status=$?

    if [ "${status}" == "7" ]; then
        printf "\nERROR: The docker service is NOT running. Please start docker.\n"
        exit -1
    fi

    printf "... docker service is running\n"
}


# DESC: Ensure that minikube is running
# ARGS: None
# OUT: None
function check_minikube_running() {
    if ! minikube status > /dev/null 2>&1 ; then
        printf "\nERROR: minikube service is NOT running. Please start minikube.\n"
        exit -1
    fi

    printf "... minikube is running\n"
}


function main {
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
        check_binary "$dep"
    done

    echo ""
    echo "--- Checking for required services ---"
    check_docker_running
    check_minikube_running
}

main