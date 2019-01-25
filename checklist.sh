#!/bin/bash

[ ! -n "$DEBUG" ] || set -x

set -u

# Hashicorp says this is better than 'set -e'
function onerr {
    echo "Cleaning up after error..."
    popd
    exit -1
}
trap onerr ERR

pushd `pwd` > /dev/null 2>&1
cd "$(dirname $0)"


function check_for_deps () {
    for dep in pidof; do
	if ! command -v "${dep}" > /dev/null 2>&1 ; then
	    printf "\nERROR: Failed to find \'${dep}\'!\n"
        echo "** If your're using a Mac, 'brew install pidof' **"
	    exit -1
	fi
    done
}


function docker_check () {
    if ! command -v docker > /dev/null 2>&1; then
        printf "\nERROR: Failed to find docker binary in path." >&2
        printf "\n** Please see https://docker.com to download and install Docker. **\n" >&2
        exit -1
    fi

    doc_running=$(curl -s --unix-socket /var/run/docker.sock http://ping > /dev/null)
    status=$?

    if [ "${status}" == "7" ]; then
        printf "\nERROR: The Docker service is NOT running. Please start Docker.\n"
        exit -1
    fi
}


function minikube_check () {
    if ! command -v minikube > /dev/null 2>&1; then
        printf "\nERROR: Failed to find minikube binary in PATH." >&2
        printf "\n** Please see https://kubernetes.io/docs/getting-started-guides/minikube/ **\n" >&2
        exit -1
    fi

    if ! minikube status > /dev/null 2>&1 ; then
        printf "ERROR: Failed to find k8s cluster running minikube. You likely need to 'minikube start'.\n" >&2
        exit -1
    fi
}


function kubectl_check () {
    if ! command -v kubectl > /dev/null 2>&1; then
	    printf "\nERROR: Failed to find kubectl binary in PATH." >&2
	    printf "\n** Please see https://kubernetes.io/docs/tasks/tools/install-kubectl/ **\n" >&2
	    exit -1
    fi
}


function consul_client_check () {
    echo "in consul_client_check"
}


function vault_client_check () {
    echo "in vault_client_check"
}


function golang_check () {
    echo "in golang_check"
}


function cfssl_check () {
    echo "in cfssl_check"
}


function main () {
    check_for_deps
    docker_check
    minikube_check
    kubectl_check
    consul_client_check
    vault_client_check
    golang_check
    cfssl_check
    popd > /dev/null 2>&1
}

main

