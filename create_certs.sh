#!/bin/bash

# Script Variables
CURRENT_DIR=$(pwd)
CERTS_DIR=$(pwd)/certs
CERTS_CONFIG_DIR=${CERTS_DIR}/config


# Script functions
function create_dir {
    DIR_NAME="$1"

    if [ ! -d ${DIR_NAME} ]; then
        mkdir -pv ${DIR_NAME}
        echo "${DIR_NAME}: created"
    else
        echo "${DIR_NAME}: already created"
    fi
}


function create_file {
    FILE_NAME="$1"
    FILE_DATA="$2"

    if [ ! -f "${FILE_NAME}" ]; then
        cat <<EOF >> "${FILE_NAME}"
${FILE_DATA}
EOF
        echo "${FILE_NAME} created"
    else
        echo "${FILE_NAME} already exists"
    fi
}


# ---------------
# Main Processing
# ---------------

# Create directory structure
echo "Creating certs directory..."
create_dir ${CERTS_CONFIG_DIR}

# Write ca-config.json
printf "\nWriting %s file...\n" "ca-config.json"
CONTENT="{
  \"signing\": {
    \"default\": {
      \"expiry\": \"87600h\"
    },
    \"profiles\": {
      \"default\": {
        \"usages\": [
          \"signing\",
          \"key encipherment\",
          \"server auth\",
          \"client auth\"
        ],
        \"expiry\": \"8760h\"
      }
    }
  }
}"

create_file "${CERTS_CONFIG_DIR}/ca-config.json" "${CONTENT}"


# Write ca-csr.json
printf "\nWriting %s file...\n" "ca-csr.json"
CONTENT="{
  \"hosts\": [
    \"cluster.local\"
  ],
  \"key\": {
    \"algo\": \"rsa\",
    \"size\": 2048
  },
  \"names\": [
    {
      \"C\": \"CA\",
      \"ST\": \"British Columbia\",
      \"L\": \"Vancouver\"
    }
  ]
}"

create_file "${CERTS_CONFIG_DIR}/ca-csr.json" "${CONTENT}"


# Write consul-csr.json
printf "\nWriting %s file...\n" "consul-csr.json"
CONTENT="{
  \"CN\": \"server.dc1.cluster.local\",
  \"hosts\": [
    \"server.dc1.cluster.local\",
    \"127.0.0.1\"
  ],
  \"key\": {
    \"algo\": \"rsa\",
    \"size\": 2048
  },
  \"names\": [
    {
      \"C\": \"CA\",
      \"ST\": \"British Columbia\",
      \"L\": \"Vancouver\"
    }
  ]
}"

create_file "${CERTS_CONFIG_DIR}/consul-csr.json" "${CONTENT}"


# Write vault-csr.json
printf "\nWriting %s file...\n" "vault-csr.json"
CONTENT="{
  \"hosts\": [
    \"vault\",
    \"127.0.0.1\"
  ],
  \"key\": {
    \"algo\": \"rsa\",
    \"size\": 2048
  },
  \"names\": [
    {
      \"C\": \"CA\",
      \"ST\": \"British Columbia\",
      \"L\": \"Vancouver\"
    }
  ]
}"

create_file "${CERTS_CONFIG_DIR}/vault-csr.json" "${CONTENT}"


# Create a Certificate Authority
printf "\nCreating a Certificate of Authority...\n"
if [ ! -f "${CERTS_DIR}/ca-key.pem" ]; then
    cfssl gencert -initca certs/config/ca-csr.json | cfssljson -bare certs/ca
    echo "Certificate Authority: created"
else
    echo "Certificate Authority: already created"
fi


# Create private key and a TLS cert for Consul
printf "\nCreating a private key and a TLS cert for Consul...\n"
if [ ! -f "${CERTS_DIR}/consul.pem" ]; then
    cfssl gencert \
      -ca=certs/ca.pem \
      -ca-key=certs/ca-key.pem \
      -config=certs/config/ca-config.json \
      -profile=default \
      certs/config/consul-csr.json | cfssljson -bare certs/consul
    echo "Consul PK and TLS: created"
else
    echo "Consul PK and TLS: already created"
fi


# Create private key and a TLS cert for Vault
printf "\nCreating a private key and a TLS cert for Vault...\n"
if [ ! -f "${CERTS_DIR}/vault.pem" ]; then
    cfssl gencert \
      -ca=certs/ca.pem \
      -ca-key=certs/ca-key.pem \
      -config=certs/config/ca-config.json \
      -profile=default \
      certs/config/vault-csr.json | cfssljson -bare certs/vault
    echo "Vault PK and TLS: created"
else
    echo "Vault PK and TLS: already created"
fi

