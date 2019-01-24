#!/bin/bash

# Ensure minikube is running or exit
if ! minikube status | grep Running &> /dev/null; then
    echo "ERROR: minicube is NOT running. Please run 'minikube start'"
    exit 1
fi


# ------------------------------------
# Store Vault certificates in a Secret
# ------------------------------------
if ! kubectl describe secret vault &> /dev/null; then
    printf "\nStoring Vault certificates in a Secret...\n"
    kubectl create secret generic vault \
      --from-file=certs/ca.pem \
      --from-file=certs/vault.pem \
      --from-file=certs/vault-key.pem
else
    printf "\nVault certificates Secret: already created\n"
fi

# Vault Certificates Secret Sanity
echo "Testing to make certain that the Vault Cerificates Secret is sane..."
if ! kubectl describe secret vault &> /dev/null; then
    echo "ERROR: can't find the Vault Cerificates Secret!"
    exit 1
else
    echo "Vault Cerificates Secret looks good"
fi


# ----------------
# Create ConfigMap
# ----------------
if ! kubectl get configmaps | grep 'vault ' &> /dev/null; then
    printf "\nCreating Vault ConfigMap...\n"
    kubectl create configmap vault --from-file=vault/config.json
else
    printf "\nVault ConfigMap: already created\n"
fi

# Vault ConfigMap Sanity
echo "Testing to see if the Vault ConfigMap is sane..."
if ! kubectl describe configmap vault &> /dev/null; then
    echo "ERROR: can't find Vault ConfigMap!"
    exit 1
else
    echo "Vault ConfigMap looks good"
fi


# ------------------
# Create the Service
# ------------------
if ! kubectl get service vault &> /dev/null; then
    printf "\nCreating Vault Service...\n"
    kubectl create -f vault/service.yaml
else
    printf "\nVault Service: already created\n"
fi

# Vault Service Sanity
echo "Testing to see if the Vault Service is sane..."
if ! kubectl get service vault &> /dev/null; then
    echo "ERROR: can't find Vault Service!"
    exit 1
else
    echo "Vault Service looks good"
fi


# ---------------------
# Create the Deployment
# ---------------------
if ! kubectl get pods | grep vault &> /dev/null; then
    printf "\nCreating Vault Deployment...\n"
    kubectl apply -f vault/deployment.yaml
else
    printf "\nVault Deployment: already created\n"
fi

# Vault Deployment Sanity
echo "Testing to see if the Vault Deployment is sane..."
if ! kubectl get pods | grep vault &> /dev/null; then
    echo "ERROR: can't find Vault Pods!"
    exit 1
else
    echo "Vault Pods look good"
fi
