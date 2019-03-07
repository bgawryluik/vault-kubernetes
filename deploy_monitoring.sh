#!/usr/bin/env bash

. ./lib/functions.sh

# DESC: Helm helper function to install a specified stable operator
# ARGS: $1 (REQ): Helm application release name
#       $2 (REQ): Helm operator name
#       $3 (REQ): Namespace
# OUT: None
function install_stable_helm_operator() {
    # Validate args
    if [[ $# -lt 3 ]]; then
        error "ERROR: Missing 3 args for install_stable_helm_operator()"
        exit -2
    fi

    # Run Helm command
    if ! helm ls --all | grep ${1} > /dev/null 2>&1; then
        helm install --name ${1} --namespace ${3} stable/${2} > /dev/null 2>&1
        success "helm operator: ${1} - ${2} has been installed"
    else
        info "helm operator: ${1} - ${2} is already installed"
    fi

    # Check Helm command sanity
    info "Testing to see if Helm operator: ${1} - ${2} is sane"
    if ! helm ls | grep ${1} | grep "DEPLOYED" > /dev/null 2>&1; then
        substep_error "ERROR: can't find Helm operator: ${1} - ${2}!"
        exit 1
    else
        substep_info "Helm operator: ${1} - ${2} looks good"
    fi

    # Wait for the Grafana pod...
    info "Checking to see if the Grafana pod is running"
    POD=$(kubectl --namespace=${ns} get pods -o=name | grep ${release}-grafana | sed "s/^.\{4\}//")

    while true; do
        STATUS=$(kubectl --namespace=${ns} get pods ${POD} -o jsonpath="{.status.phase}")

        if [ "$STATUS" == "Running" ]; then
            substep_info "Pod status is: RUNNING"
            break
        else
            substep_info "Pod status is: ${STATUS}"
            sleep 10
        fi

    done
}


# DESC: MAIN PROCESSING
# ARGS: None
# OUT: None
function main() {
    local release="minikube"
    local name="prometheus-operator"
    local ns="monitoring"
    local grafana_port=3000

    echo ""
    echo "--- Installing the Helm Prometheus Operator ---"
    install_stable_helm_operator ${release} ${name} ${ns}

    POD=$(kubectl --namespace=${ns} get pods -o=name | grep ${release}-grafana | sed "s/^.\{4\}//")
    echo ""
    echo ""--- Forwarding port ${grafana_port} for ${POD} ---
    k8s_port_forwarding ${POD} ${grafana_port} ${grafana_port} ${ns}
}

main
