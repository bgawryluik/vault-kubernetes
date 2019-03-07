#!/usr/bin/env bash

# DESC: Creates a k8s ConfigMap
# ARGS: $1 (REQ): Application Name
#       $2 (OPT): Namespace
# OUT: None
function k8s_configmap() {
    # Validate args
    if [[ $# -lt 1 ]]; then
        error "ERROR: Missing 1 arg for k8s_configmap()"
        exit -2
    fi

    # Set namespace
    if [ -z ${2+x} ]; then
         local ns="default"
     else
         local ns="${2}"
    fi

    # Run K8s command
    if ! kubectl --namespace=${ns} get configmaps | grep ${1} > /dev/null 2>&1; then
        kubectl --namespace=${ns} create configmap ${1} --from-file=${1}/config.json
        success "${1} ConfigMap created"
    else
        info "${1} ConfigMap was already created"
    fi

    # Check K8s command sanity
    info "Testing to see if the ${1} ConfigMap is sane"
    if ! kubectl --namespace=${ns} describe configmap ${1} > /dev/null 2>&1; then
        substep_error "ERROR: can't find the ${1} ConfigMap!"
        exit 1
    else
        substep_info "${1} ConfigMap looks good"
    fi
}


# DESC: Deletes a k8s ConfigMap
# ARGS: $1 (REQ): Application Name
#       $2 (OPT): Namespace
# OUT: None
function k8s_configmap_delete() {
    # Validate args
    if [[ $# -lt 1 ]]; then
        error "ERROR: Missing 1 arg for k8s_configmap_delete()"
        exit -2
    fi

    # Set namespace
    if [ -z ${2+x} ]; then
        local ns="default"
    else
        local ns="${2}"
    fi

    # Run K8s command
    if kubectl --namespace=${ns} get configmaps | grep ${1} > /dev/null 2>&1; then
        kubectl --namespace=${ns} delete configmap ${1}
        success "Deleted ConfigMap for ${1}"
    else
        info "ConfigMap for ${1} was already deleted"
    fi
}


# DESC: Create a K8s CRD
# ARGS: TODO
# OUT: NONE
function k8s_crd() {
    echo "TODO"
}


# DESC: Deletes K8s CRD
# ARGS: $1 (REQ): CRD name
# OUT: NONE
function k8s_crd_delete() {
    # Validate args
    if [[ $# -lt 1 ]]; then
        error "ERROR: Missing arg k8s_crd_deletefor ()"
        exit -2
    fi

    # Run K8s command
    if kubectl get crds | grep ${1} > /dev/null 2>&1; then
        kubectl delete crd ${1} > /dev/null 2>&1
        success "Deleted CRD: ${1}"
    else
        info "CRD: ${1} was already deleted"
    fi
}


# DESC: Creates a K8s Deployment
# ARGS: $1 (REQ): Application Name
#       $2 (OPT): Namespace
# OUT: None
function k8s_deployment() {
    # Validate args
    if [[ $# -lt 1 ]]; then
        error "ERROR: Missing 1 arg for k8s_deployment()"
        exit -2
    fi

    # Set namespace
    if [ -z ${2+x} ]; then
        local ns="default"
    else
        local ns="${2}"
    fi

    # Run the K8s command
    if ! kubectl --namespace=${ns} get pods | grep ${1} > /dev/null 2>&1; then
        kubectl --namespace=${ns} apply -f ${1}/deployment.yaml
        success "${1} Deployment applied"

        # Wait for pods to launch
        substep_info "Waiting for ${1} pods to launch"
        sleep 15

        POD=$(kubectl --namespace=${ns} get pods -o=name | grep ${1} | sed "s/^.\{4\}//")

        while true; do
            STATUS=$(kubectl --namespace=${ns} get pods ${POD} -o jsonpath="{.status.phase}")

            if [ "$STATUS" == "Running" ]; then
                substep_info "Pod status is: RUNNING"
                break
            else
                substep_info "Pod status is: ${STATUS}"
                sleep 5
            fi

        done

    else
        info "${1} Deployment was already applied"
    fi

    # Check K8s command sanity
    info "Testing to see if the ${1} Deployment is sane"
    if ! kubectl --namespace=${ns} get pods | grep ${1} > /dev/null 2>&1; then
        substep_error "ERROR: can't find ${1} Pods!"
        exit 1
    else
        substep_info "${1} Pods look good"
    fi
}


# DESC: Deletes a K8s Deployment
# ARGS: $1 (REQ): Application Name
#       $2 (OPT): Namespace
# OUT: None
function k8s_deployment_delete() {
    # Validate args
    if [[ $# -lt 1 ]]; then
        error "ERROR: Missing 1 arg for k8s_deployment_delete()"
        exit -2
    fi

    # Set namespace
    if [ -z ${2+x} ]; then
        local ns="default"
    else
        local ns="${2}"
    fi

    # Run the K8s command
    if kubectl --namespace=${ns} get pods | grep ${1} > /dev/null 2>&1; then
        kubectl --namespace=${ns} delete deployment ${1}
        success "Deleted Deployment for ${1}"
    else
        info "Deployment for ${1} was already deleted"
    fi
}


# DESC: Creates a K8s namespace
# ARGS: TODO
# OUT: NONE
function k8s_namespace() {
    echo "TODO"
}


# DESC: Deletes a K8s namespace
# ARGS: $1 (REQ): Namespace name
# OUT: NONE
function k8s_namespace_delete() {
    # Validate args
    if [[ $# -lt 1 ]]; then
        error "ERROR: Missing arg for k8s_namespace_delete()"
        exit -2
    fi

    # Run the K8s command
    if kubectl get namespaces | grep ${1} > /dev/null 2>&1; then
        substep_info "...this could take a few moments"
        kubectl delete namespace ${1} > /dev/null 2>&1
        success "Deleted Namespace ${1}"
    else
        info "Namespace ${1} was already deleted"
    fi
}


# DESC: Deletes a K8s Secret
# ARGS: $1 (REQ): Application Name
#       $2 (OPT): Namespace
# OUT: None
function k8s_secret_delete() {
    # Validate args
    if [[ $# -lt 1 ]]; then
        error "ERROR: Missing 1 arg for k8s_secret_delete()"
        exit -2
    fi

    # Set namespace
    if [ -z ${2+x} ]; then
        local ns="default"
    else
        local ns="${2}"
    fi

    # Run the K8s command
    if kubectl --namespace=${ns} get secret ${1} > /dev/null 2>&1; then
        kubectl --namespace=${ns} delete secret ${1}
        success "Deleted Secret for ${1}"
    else
        info "Secret for ${1} was already deleted"
    fi
}


# DESC: Creates a k8s Service
# ARGS: $1 (REQ): Application Name
#       $2 (OPT): Namespace
# OUT: None
function k8s_service() {
    # Validate args
    if [[ $# -lt 1 ]]; then
        error "ERROR: Missing 1 arg for k8s_service()"
        exit -2
    fi

    # Set namespace
    if [ -z $2+x} ]; then
         local ns="default"
     else
         local ns="${2}"
    fi

    # Run K8s command
    if ! kubectl --namespace=${ns} get service ${1} | grep ${1} > /dev/null 2>&1; then
        kubectl --namespace=${ns} create -f ${1}/service.yaml
        success "${1} Service created"
    else
        info "${1} Service was already created"
    fi

    # Check K8s command sanity
    info "Testing to see if the ${1} Service is sane"
    if ! kubectl --namespace=${ns} get service ${1} > /dev/null 2>&1; then
        substep_error "ERROR: can't find the ${1} Service!"
        exit 1
    else
        substep_info "${1} Service looks good"
    fi
}


# DESC: Deletes a k8s Service
# ARGS: $1 (REQ): Application Name
#       $2 (OPT): Namespace
# OUT: None
function k8s_service_delete() {
    # Validate args
    if [[ $# -lt 1 ]]; then
        error "ERROR: Missing 1 arg for k8s_service_delete()"
        exit -2
    fi

    # Set namespace
    if [ -z $2+x} ]; then
        local ns="default"
    else
        local ns="${2}"
    fi

    # Run the K8s command
    if kubectl --namespace=${ns} get service | grep ${1} > /dev/null 2>&1; then
        kubectl --namespace=${ns} delete service ${1}
        success "Deleted Service for ${1}"
    else
        info "Service for ${1} was already deleted"
    fi
}


# DESC: Creates a k8s StatefulSet
# ARGS: $1 (REQ): Application Name
#       $2 (OPT): Namespace
# OUT: None
function k8s_statefulset() {
    # Validate args
    if [[ $# -lt 1 ]]; then
        error "ERROR: Missing 1 arg for k8s_statefulset()"
        exit -2
    fi

    # Set namespace
    if [ -z $2+x} ]; then
        local ns="default"
    else
        local ns="${2}"
    fi

    # Run K8s command
    if ! kubectl --namespace=${ns} get pods | grep ${1} > /dev/null 2>&1; then
        kubectl --namespace=${ns} create -f ${1}/statefulset.yaml > /dev/null 2>&1
        success "${1} StatefulSet created"

        # Wait for pods to launch
        substep_info "Waiting for ${1} pods to launch"
        sleep 15

        #POD=$(kubectl --namespace=${ns} get pods -o=name | grep ${1}-1 | sed "s/^.\{4\}//")
        POD=${1}-1

        while true; do
            STATUS=$(kubectl --namespace=${ns} get pods ${POD} -o jsonpath="{.status.phase}")

            if [ "$STATUS" == "Running" ]; then
                substep_info "Pod status is: RUNNING"
                break
            else
                substep_info "Pod status is: ${STATUS}"
                sleep 5
            fi

        done

    else
        info "${1} StatefulSet was already created"
    fi

    # Check K8s command sanity
    info "Testing to see if the ${1} StatefulSet is sane..."
    if ! kubectl --namespace=${ns} get pods | grep ${1} > /dev/null 2>&1; then
        substep_error "ERROR: can't find ${1} Pods!"
        exit 1
    else
        substep_info "${1} Pods look good"
    fi
}


# DESC: Deletes a k8s StatefulSet
# ARGS: $1 (REQ): Application Name
#       $2 (OPT): Namespace
# OUT: None
function k8s_statefulset_delete() {
    # Validate args
    if [[ $# -lt 1 ]]; then
        error "ERROR: Missing 1 arg for k8s_statefulset_delete()"
        exit -2
    fi

    # Set namespace
    if [ -z $2+x} ]; then
        local ns="default"
    else
        local ns="${2}"
    fi

    # Run K8s command
    if kubectl --namespace=${ns} get pods | grep ${1} > /dev/null 2>&1; then
        kubectl --namespace=${ns} delete statefulset ${1}
        success "Deleted StatefulSet for ${1}"
    else
        info "StatefulSet for ${1} was already deleted"
    fi
}


# DESC: Perform port-forwarding in the background
# ARGS: #1 (REQ): pod name
#       $2 (REQ): local port
#       $3 (REQ): pod port
#       $4 (OPT): namespace
# OUT: None
function k8s_port_forwarding() {
    # Validate args
    if [[ $# -lt 3 ]]; then
        error "ERROR: Missing 3 args for k8s_port_forwarding()"
        exit -2
    fi

    # Set namespace
    if [ -z ${4+x} ]; then
        local ns="default"
    else
        local ns="${4}"
    fi

    # Run K8s command
    if ! ps aux | grep "[k]ubectl --namespace=${ns} port-forward" | grep ${1} > /dev/null 2>&1; then
        kubectl --namespace=${ns} port-forward ${1} ${2}:${3} &
        success "${1}: forwarding local port ${2} to pod port ${3}"
    else
        info "${1}: already forwarding local port ${2} to pod port ${3}"
    fi

    # Check K8s command sanity
    info "Testing to see if ${1}: forwarding pod port ${3} is sane"
    if ! ps aux | grep "[k]ubectl --namespace=${ns} port-forward" | grep ${1} | grep ${2} > /dev/null 2>&1; then
        substep_error "ERROR: Not Port-Forwarding ${1}: pod port ${3}!"
    else
        substep_info "Port-Forwarding ${1}: port ${3} looks good"
    fi
}


# DESC: Delete persistent volume claims
# ARGS: $1: (REQ): Application Name (label)
#       $2: (OPT): Namespace
# OUT: NONE
function k8s_pvc_delete() {
    # Validate args
    if [[ $# -lt 1 ]]; then
        error "ERROR: Missing 1 args for k8s_pvc_delete()"
        exit -2
    fi

    # Set namespace
    if [ -z ${2+x} ]; then
        local ns="default"
    else
        local ns="${2}"
    fi

    # Run the K8s command
    if kubectl --namespace=${ns} get pvc | grep ${1} > /dev/null 2>&1; then
        kubectl --namespace=${ns} delete pvc -l app=${1}
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
