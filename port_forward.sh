#!/bin/bash

# Ensure minikube is running or exit
if ! minikube status | grep Running &> /dev/null; then
    echo "ERROR: minicube is NOT running. Please run 'minikube start'"
    exit 1
fi


# ------------------
# Set Vault ENV Vars
# ------------------
echo "Setting Vault ENV Vars"
export VAULT_ADDR=https://127.0.0.1:8200
export VAULT_CACERT="certs/ca.pem"

# ------------------
# Port forward Vault
# ------------------
echo "Forwarding Vault port (8200) when pods are ready..."
echo "You can view the UI at: $VAULT_ADDR"

POD=$(kubectl get pods -o=name | grep vault | sed "s/^.\{4\}//")

while true; do
  STATUS=$(kubectl get pods ${POD} -o jsonpath="{.status.phase}")
  if [ "$STATUS" == "Running" ]; then
    break
  else
    echo "Pod status is: ${STATUS}"
    sleep 5
  fi
done

kubectl port-forward $POD 8200:8200
