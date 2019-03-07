#!/usr/bin/env bash

# DESC: Creates a k8s ConfigMap
# ARGS: $1 (REQ): Application Name
# OUT: None
function k8s_configmap() {
    if [[ $# -lt 1 ]]; then
        error "ERROR: Missing 1 arg for k8s_configmap()"
        exit -2
    fi

    if ! kubectl get configmaps | grep ${1} > /dev/null 2>&1; then
        kubectl create configmap ${1} --from-file=${1}/config.json
        success "${1} ConfigMap created"
    else
        info "${1} ConfigMap was already created"
    fi

    # K8s ConfigMap Sanity
    printf "Testing to see if the ${1} ConfigMap is sane...\n"
    if ! kubectl describe configmap ${1} > /dev/null 2>&1; then
        substep_error "ERROR: can't find the ${1} ConfigMap!"
        exit 1
    else
        substep_info "${1} ConfigMap looks good"
    fi
}

# DESC: Deletes a k8s ConfigMap
# ARGS: $1 (REQ): Application Name
# OUT: None
function k8s_configmap_delete() {
    if [[ $# -lt 1 ]]; then
        error "ERROR: Missing 1 arg for k8s_configmap_delete()"
        exit -2
    fi

    if kubectl get configmaps | grep ${1} > /dev/null 2>&1; then
        kubectl delete configmap ${1}
        success "Deleted ConfigMap for ${1}"
    else
        info "ConfigMap for ${1} was already deleted"
    fi
}

# DESC: Creates a k8s Deployment
# ARGS: $1 (REQ): Application Name
# OUT: None
function k8s_deployment() {
    if [[ $# -lt 1 ]]; then
        error "ERROR: Missing 1 arg for k8s_deployment()"
        exit -2
    fi

    if ! kubectl get pods | grep ${1} > /dev/null 2>&1; then
        kubectl apply -f ${1}/deployment.yaml
        success "${1} Deployment applied"

        # Wait for pods to launch
        substep_info "... waiting for ${1} pods to launch"
        sleep 10

        POD=$(kubectl get pods -o=name | grep ${1} | sed "s/^.\{4\}//")
        while true; do
            STATUS=$(kubectl get pods ${POD} -o jsonpath="{.status.phase}")
            if [ "$STATUS" == "Running" ]; then
                break
            else
                substep_info "Pod status is: ${STATUS}"
                sleep 5
            fi
        done
    else
        info "${1} Deployment was already applied"
    fi

    # K8s Deployment Sanity
    printf "Testing to see if the ${1} Deployment is sane...\n"
    if ! kubectl get pods | grep ${1} > /dev/null 2>&1; then
        substep_error "ERROR: can't find ${1} Pods!"
        exit 1
    else
        substep_info "${1} Pods look good"
    fi
}

# DESC: Deletes a k8s Deployment
# ARGS: $1 (REQ): Application Name
# OUT: None
function k8s_deployment_delete() {
    if [[ $# -lt 1 ]]; then
        error "ERROR: Missing 1 arg for k8s_deployment_delete()"
        exit -2
    fi

    if kubectl get pods | grep ${1} > /dev/null 2>&1; then
        kubectl delete deployment ${1}
        success "Deleted Deployment for ${1}"
    else
        info "Deployment for ${1} was already deleted"
    fi
}

# DESC: Deletes a k8s Secret
# ARGS: $1 (REQ): Application Name
# OUT: None
function k8s_secret_delete() {
    if [[ $# -lt 1 ]]; then
        error "ERROR: Missing 1 arg for k8s_secret_delete()"
        exit -2
    fi

    if kubectl get secret ${1} > /dev/null 2>&1; then
        kubectl delete secret ${1}
        success "Deleted Secret for ${1}"
    else
        info "Secret for ${1} was already deleted"
    fi
}

# DESC: Creates a k8s Service
# ARGS: $1 (REQ): Application Name
# OUT: None
function k8s_service() {
    if [[ $# -lt 1 ]]; then
        error "ERROR: Missing 1 arg for k8s_service()"
        exit -2
    fi

    if ! kubectl get service ${1} | grep ${1} > /dev/null 2>&1; then
        kubectl create -f ${1}/service.yaml
        success "${1} Service created"
    else
        info "${1} Service was already created"
    fi

    # K8s Service Sanity
    printf "Testing to see if the ${1} Service is sane...\n"
    if ! kubectl get service ${1} > /dev/null 2>&1; then
        substep_error "ERROR: can't find the ${1} Service!"
        exit 1
    else
        substep_info "${1} Service looks good"
    fi
}

# DESC: Deletes a k8s Service
# ARGS: $1 (REQ): Application Name
# OUT: None
function k8s_service_delete() {
    if [[ $# -lt 1 ]]; then
        error "ERROR: Missing 1 arg for k8s_service_delete()"
        exit -2
    fi

    if kubectl get service | grep ${1} > /dev/null 2>&1; then
        printf "... deleting Service for ${1}\n"
        kubectl delete service ${1}
        success "Deleted Service for ${1}"
    else
        info "Service for ${1} was already deleted"
    fi
}

# DESC: Creates a k8s StatefulSet
# ARGS: $1 (REQ): Application Name
# OUT: None
function k8s_statefulset() {
    if [[ $# -lt 1 ]]; then
        error "ERROR: Missing 1 arg for k8s_statefulset()"
        exit -2
    fi

    if ! kubectl get pods | grep ${1} > /dev/null 2>&1; then
        kubectl create -f ${1}/statefulset.yaml
        success "${1} StatefulSet created"

        # Wait for pods to launch
        substep_info "... waiting for ${1} pods to launch"
        sleep 10
        POD=$(kubectl get pods -o=name | grep ${1}-1 | sed "s/^.\{4\}//")
        while true; do
            STATUS=$(kubectl get pods ${POD} -o jsonpath="{.status.phase}")
            if [ "$STATUS" == "Running" ]; then
                break
            else
                substep_info "Pod status is: ${STATUS}"
                sleep 5
            fi
        done
    else
        info "${1} StatefulSet was already created"
    fi

    # K8s StatefulSet Sanity
    info "Testing to see if the ${1} StatefulSet is sane..."
    if ! kubectl get pods | grep ${1} > /dev/null 2>&1; then
        substep_error "ERROR: can't find ${1} Pods!"
        exit 1
    else
        substep_info "${1} Pods look good"
    fi
}

# DESC: Deletes a k8s StatefulSet
# ARGS: $1 (REQ): Application Name
# OUT: None
function k8s_statefulset_delete() {
    if [[ $# -lt 1 ]]; then
        error "ERROR: Missing 1 arg for k8s_statefulset_delete()"
        exit -2
    fi

    if kubectl get pods | grep ${1} > /dev/null 2>&1; then
        kubectl delete statefulset ${1}
        success "Deleted StatefulSet for ${1}"
    else
        info "StatefulSet for ${1} was already deleted"
    fi
}

# DESC: Perform port-forwarding in the background
# ARGS: #{1} (REQ): pod name
#       ${2} (REQ): local port
#       ${3} (REQ): pod port
#       ${4} (OPT): namespace
# OUT: None
function k8s_port_forwarding() {
    if [[ $# -lt 3 ]]; then
        error "ERROR: Missing 3 args for k8s_port_forwarding()"
        exit -2
    fi

    # Set namespace
    if [ -z ${4+x} ]; then
        local namespace="default"
    else
        local namespace="${4}"
    fi

    if ! ps aux | grep "[k]ubectl --namespace=${namespace} port-forward" | grep ${1} > /dev/null 2>&1; then
        kubectl --namespace=${namespace} port-forward ${1} ${2}:${3} &
        success "${1}: forwarding local port ${2} to pod port ${3}"
    else
        info "${1}: already forwarding local port ${2} to pod port ${3}"
    fi

    # K8s Port-Forwarding Sanity
    info "Testing to see if ${1}: forwarding pod port ${3} is sane"
    if ! ps aux | grep "[k]ubectl --namespace=${namespace} port-forward" | grep ${1} | grep ${2} > /dev/null 2>&1; then
        substep_error "ERROR: Not Port-Forwarding ${1}: pod port ${3}!"
    else
        substep_info "Port-Forwarding ${1}: pod port ${3} looks good"
    fi
}

# DESC: Delete persistent volume claims
# ARGS: $1: (REQ) application name (label)
# OUT: NONE
function k8s_pvc_delete() {
    if [[ $# -lt 1 ]]; then
        error "ERROR: Missing 1 args for k8s_pvc_delete()"
        exit -2
    fi

    if kubectl get pvc | grep ${1} > /dev/null 2>&1; then
        kubectl delete pvc -l app=${1}
        success "Deleted persistent volume claims for ${1}"
    else
        info "Persistent volume claims for ${1} were already deleted"
    fi
}

# DESC: Pretty printing functions inspired from https://github.com/Sajjadhosn/dotfiles
# ARGS: $1 (REQ): String text message
#       $2 (REQ): Text color
#       $3 (REQ): Arrow (string representation)
# OUT: NONE
function coloredEcho() {
    local color="${2}"
    if ! [[ ${color} =~ '^[0-9]$' ]]; then
        case $(echo ${color} | tr '[:upper:]' '[:lower:]') in
            black)   color=0 ;;
            red)     color=1 ;;
            green)   color=2 ;;
            yellow)  color=3 ;;
            blue)    color=4 ;;
            magenta) color=5 ;;
            cyan)    color=6 ;;
            white|*) color=7 ;;
        esac
    fi

    tput bold
    tput setaf "${color}"
    echo "${3} ${1}"
    tput sgr0
}

# DESC: Print an info message
# ARGS: $1: String text message
# OUT: printed string message
function info() {
    coloredEcho "${1}" blue "========>"
}

# DESC: Print a success message
# ARGS: $1: String text message
# OUT: printed string message
function success() {
    coloredEcho "${1}" green "========>"
}

# DESC: Print an error message
# ARGS: $1: String text message
# OUT: printed string message
function error() {
    coloredEcho "${1}" red "========>"
}

# DESC: print a substep info message
# ARGS: $1: String text message
# OUT: printed string message
function substep_info() {
    coloredEcho "${1}" magenta "===="
}

# DESC: print a substep success message
# ARGS: $1: String text message
# OUT: printed string message
function substep_success() {
    coloredEcho "${1}" cyan "===="
}

# DESC: print a substep error message
# ARGS: $1: String text message
# OUT: printed string message
function substep_error() {
    coloredEcho "${1}" red "===="
}
