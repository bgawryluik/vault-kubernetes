#!/usr/bin/env bash

# DESC: Create required directories
# ARGS: $1 (REQ): Name of the dir to be created
# OUT: None
function make_dirs() {
  if [[ $# -lt 1 ]]; then
    printf "\nERROR: Missing arg for make_dirs()\n"
    exit -2
  fi

  if [ ! -d ./$1 ]; then
    mkdir -p ./$1
    printf "... $1 directory created\n"
    return
  fi

  printf "... $1 directory is already created\n"
}


# DESC: Use CFSSL to create a Certificate Authority
# ARGS: $1 (REQ) - Cert destination path
#       $2 (REQ) - Config file (JSON) path
# OUT: None
function create_ca() {
  if [[ $# -lt 2 ]]; then
    printf "\nERROR: Missing 2 args for create_ca()\n"
    exit -2
  fi 

  if [ ! -f ./${1}.pem ]; then
    cfssl gencert -initca ./${2} | cfssljson -bare ./${1}
    printf "... ${1} Certificate Authority created\n"
    return
  fi

  printf "... ${1} Certificate Authority is already created\n"  
}

# DESC: Use CFSSL to create Private Key and TLS certificates
# ARGS: $1 (REQ): Cert dir
#       $2 (REQ): Config dir
#       $3 (REQ): Cert file name
# OUT: None
function create_certs() {
  if [[ $# -lt 3 ]]; then
    printf "\nERROR: Missing 3 args for create_certs()\n"
    exit -2
  fi 

  if [ ! -f ./${1}/${3}.pem ]; then
    cfssl gencert \
      -ca=${1}/ca.pem \
      -ca-key=${1}/ca-key.pem \
      -config=${2}/ca-config.json \
      -profile=default \
      ${2}/${3}-csr.json | cfssljson -bare ./${1}/${3}
    printf "... ${3} PK and TLS created\n"
    return
  fi

  printf "... ${3} PK and TLS are already created\n"
}


# DESC: MAIN PROCESSING
# ARGS: None
# OUT: None
function main() {
  local certs_dir="certs"
  local conf_dir="config"
  local consul_cert="consul"
  local vault_cert="vault"

  echo "--- Creating certificate directory ---"
  make_dirs ${certs_dir}

  echo ""
  echo "--- Creating Certificate Authority ---"
  create_ca ${certs_dir}/ca ${conf_dir}/ca-csr.json

  echo ""
  echo "--- Creating Priviate Key and TLS cert for Consul ---"
  create_certs ${certs_dir} ${conf_dir} ${consul_cert} 
  
  echo ""
  echo "--- Creating Priviate Key and TLS cert for Vault ---"
  create_certs ${certs_dir} ${conf_dir} ${vault_cert}
}

main
