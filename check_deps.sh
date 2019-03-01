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

    info "${1} is in your PATH"
}

# DESC: Ensure that AWS CLI Credentials are configured
# ARGS: None
# OUT: None
function check_aws_cli_credentials() {
    if ! aws sts get-caller-identity > /dev/null 2>&1 ; then
        printf "\nERROR: AWS CLI credentials are NOT configured. Run 'aws configure'"
        exit -1
    fi

    info "AWS CLI credentials are configured"
}

# DESC: MAIN PROCESSING
# ARGS: None
# OUT: None
function main() {
    echo "--- Checking for required binaries ---"
    local deps=(
        "aws"
        "aws-iam-authenticator"
        "kubectl"
        "eksctl"
        "consul"
        "vault"
        "go"
        "cfssl"
    )

    # check for required binaries
    for dep in "${deps[@]}"; do
        check_binary "${dep}"
    done

    echo "--- Checking for AWS CLI credentials ---"
    check_aws_cli_credentials
}

main
