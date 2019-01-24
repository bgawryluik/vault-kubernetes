#!/bin/bash

# Ensure minikube is running or exit
if ! minikube status | grep Running &> /dev/null; then
    echo "ERROR: minicube is NOT running. Please run 'minikube start'"
    exit 1
fi

# ------------------------------
# Generate Gossip Encryption Key
# ------------------------------
if ! kubectl get secrets | grep 'consul ' &> /dev/null; then
    printf "\nGenerating Gossip Encryption Key...\n"
    export GOSSIP_ENCRYPTION_KEY=$(consul keygen)

    kubectl create secret generic consul \
      --from-literal="gossip-encryption-key=${GOSSIP_ENCRYPTION_KEY}" \
      --from-file=certs/ca.pem \
      --from-file=certs/consul.pem \
      --from-file=certs/consul-key.pem
else
    printf "\nGossip Encryption Key: already created\n"
fi

# Gossip Encryption Key Sanity
echo "Testing to make certain that the Gossip Encryption Key is sane..."
if ! kubectl describe secret consul &> /dev/null; then
    echo "ERROR: can't find the Gossip Encryption Key!"
    exit 1
else
    echo "Gossip Encryption Key looks good"
fi


# ----------------
# Create ConfigMap
# ----------------
if ! kubectl get configmaps | grep 'consul ' &> /dev/null; then
    printf "\nCreating Consul ConfigMap...\n"
    kubectl create configmap consul --from-file=consul/config.json
else
    printf "\nConsul ConfigMap: already created\n"
fi

# Consul ConfigMap Sanity
echo "Testing to see if the Consul ConfigMap is sane..."
if ! kubectl describe configmap consul &> /dev/null; then
    echo "ERROR: can't find Consul ConfigMap!"
    exit 1
else
    echo "Consul ConfigMap looks good"
fi


# ------------------
# Create the Service
# ------------------
if ! kubectl get service consul | grep consul &> /dev/null; then
    printf "\nCreating Consul Service...\n"
    kubectl create -f consul/service.yaml
else
    printf "\nConsul Service: already created\n"
fi

# Consul Service Sanity
echo "Testing to see if the Consul Service is sane..."
if ! kubectl get service consul &> /dev/null; then
    echo "ERROR: can't find Consul Service!"
    exit 1
else
    echo "Consul Service looks good"
fi


# ----------------------
# Create the StatefulSet
# ----------------------
if ! kubectl get pods | grep consul &> /dev/null; then
    printf "\nCreating Consul StatefulSet...\n"
    kubectl create -f consul/statefulset.yaml
else
    printf "\nConsul StatefulSet: already created\n"
fi

# Consul StatefulSet Sanity
echo "Testing to see if the Consul StatefulSet is sane..."
if ! kubectl get pods | grep consul &> /dev/null; then
    echo "ERROR: can't find Consul Pods!"
    exit 1
else
    echo "Consul Pods look good"
fi
