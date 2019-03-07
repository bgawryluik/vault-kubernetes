#!/usr/bin/env bash

. ./lib/functions.sh

# DESC: Helm helper function to install a specified stable operator
# ARGS: $1 (REQ): Helm application release name
#       $2 (REQ): Helm operator name
#       $3 (REQ): K8s namespace
# OUT: None
function install_stable_helm_operator() {
    if [[ $# -lt 3 ]]; then
        error "ERROR: Missing 3 args for install_stable_helm_operator()"
        exit -2
    fi

    if ! helm ls --all | grep ${1} > /dev/null 2>&1; then
        helm install --name ${1} --namespace ${3} stable/${2} > /dev/null 2>&1
        success "helm operator: ${1} - ${2} has been installed"
    else
        info "helm operator: ${1} - ${2} is already installed"
    fi

    # Helm Operator Sanity
    printf "Testing to see if Helm operator: ${1} - ${2} is sane...\n"
    if ! helm ls | grep ${1} | grep "DEPLOYED"; then
        substep_error "ERROR: can't find Helm operator: ${1} - ${2}!"
        exit 1
    else
        substep_info "Helm operator: ${1} - ${2} looks good"
    fi
}

# DESC: MAIN PROCESSING
# ARGS: None
# OUT: None
function main() {
    local op_release_name="minikube"
    local op_name="prometheus-operator"
    local op_k8s_namespace="monitoring"
    local op_grafana_port=3000

    echo ""
    echo "--- Installing the Helm Prometheus Operator ---"
    install_stable_helm_operator ${op_release_name} ${op_name} ${op_k8s_namespace}

    local op_grafana_pod=$(kubectl --namespace=${op_k8s_namespace} get pods -o=name | grep ${op_release_name}-grafana | sed "s/^.\{4\}//")
    echo ""
    echo ""--- Forwarding port ${op_grafana_port} for ${op_grafana_pod} ---
    k8s_port_forwarding ${op_grafana_pod} ${op_grafana_port} ${op_grafana_port} ${op_k8s_namespace}
}

main
