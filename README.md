# Hashicorp's Vault using Kubernetes
## Running Vault and Consul on Kubernetes

Based on the blog [post](https://testdriven.io/blog/running-vault-and-consul-on-kubernetes/) create by [Michael Herman](https://github.com/mjhea0).

## Requirements

### Docker v18.09.0

### Kubernetes v1.10.0

### Minikube

[Minikube](https://kubernetes.io/docs/setup/minikube/) is a single-node kubernetes cluster that is used to test the Kubernetes API running K8s applications on your workstation. This is how you run it using VirtualBox as your Hypervisor.

#### MacOS
```
$ brew update
$ brew install kubectl
$ brew cask install virtualbox
$ brew cask install minikube
```

#### Ubuntu 18.04
I just followed the instructions listed here: [How to Install Minikube on Ubuntu 18.04](https://computingforgeeks.com/how-to-install-minikube-on-ubuntu-18-04/).

### Hashicorp's Consul client
Follow the instructions listed [here](https://www.consul.io/docs/install/index.html). The original blog post recommends `v1.4.0`.

### Hashicorp's Vault client
Follow the instructions listed [here](https://www.vaultproject.io/docs/install/). The original blog post recommends `v0.11.5`.

### The Go Programming Language
The blog post has great instructions for installing Go on a Mac. Google has plenty of instructions for every other OS. Just make certain that you remember to set you `GOPATH` variable.  

Example:
```
$ mkdir $HOME/go
$ export GOPATH=$HOME/go
$ export PATH=$PATH:$GOPATH/bin
```

### Cloudflare's cfssl toolkit
Once you've got GO properly installed and configured, just run:
```
$ go get -u github.com/cloudflare/cfssl/cmd/cfssl
$ go get -u github.com/cloudflare/cfssl/cmd/cfssljson
```
And that's it. The scripts included in this repository should take care of the rest.

## Getting Started

### Start the cluster
```
$ minikube start --vm-driver=virtualbox
$ minikube dashboard
```

### Clone this repo
Kind of goes without saying. Clone and then navigate as follows:
```
$ cd vault-kubernetes
```

### Deploy the cluster
```
$ make workstation
```

## Quick Test
With port forwarding still on, in a new terminal window, navigate to the project directory and set the `VAULT_ADDR` and `VAULT_CACERT` environment variables:
```
$ export VAULT_ADDR=https://127.0.0.1:8200
$ export VAULT_CACERT="certs/ca.pem"
```

Ensure Vault client is installed. Then init Vault with a single key:
```
vault operator init -key-shares=1 -key-threshold=1
```

Take note of the unseal key and the initial root token.
```
Unseal Key 1: F0Snz/ubK2IEdQ4a8WGECianyueTiIwsKAvV0XXYp4Y=

Initial Root Token: 8GIwICNI9Pn3dO9JFNnuUhTi
```

Unseal Vault:
```
$ vault operator unseal
Unseal Key (will be hidden):
```

Authenticate with the root token:
```
$ vault login
Token (will be hidden):
```

Create a test secret:
```
$ vault kv put secret/precious foo=bar

Success! Data written to: secret/precious
```

Read the test secret:
```
$ vault kv get secret/precious
=== Data ===
Key    Value
---    -----
foo    bar
```

When you are done, bring down the cluster. First you should stop port-forwarding. Then you can destroy the minikube cluster. 
```
$ pkill kubectl
$ minikube destroy
```
