# Hashicorp's Vault using Kubernetes
## Running Vault (and Consul and Prometheus and Grafana) on Kubernetes
Based on this blog [post](https://testdriven.io/blog/running-vault-and-consul-on-kubernetes/) create by [Michael Herman](https://github.com/mjhea0). This started as project to simply run Vault in Kubernetes. It's slowly morphing into a K8s development platform that includes Vault, Consul, [Prometheus](https://prometheus.io/), and [Grafana](https://grafana.com/).

**NOTE**: these instuctions assume that your workstation is a Mac. For example, this installation was tested on a 2017 MacBook (3.1GHz Intel Core I7 with 16GB of memory) running macOS Mojave (v10.14.2).

## Requirements
It is much easier to follow these instruction if you already have [Homebrew](https://brew.sh/) installed on your Mac. Click this [link](https://brew.sh/) for installation instructions.

| Requirement | My Version | Installation Instrunctions |
| ----------- | ------- | -------------------------- |
| [Docker](https://docs.docker.com/docker-for-mac/install/) | 18.09.1 | `brew install docker` |
| [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/) | Client Version: v1.13.2 | `brew install kubectl` |
| [minikube](https://kubernetes.io/docs/tasks/tools/install-minikube/) | v0.30.0 | `brew cask install virtualbox; brew cask install minikube` |
| [Helm](https://helm.sh) | Client Version: v2.13.0 | `brew install kubernetes-helm` | 
| Hashicorp [consul](https://www.consul.io/) client | v1.4.0 | `brew install consul` |
| Hashicorp [vault](https://www.vaultproject.io/) client| v1.0.2 | `brew install vault` |
| [Golang](https://golang.org/doc/install) | 1.11.5 | `brew install go --cross-compile-common` |

### Configuring Golang

Make certain that you remember to set your `GOPATH` variable.  

Example:
```
$ mkdir $HOME/go
$ export GOPATH=$HOME/go
$ export PATH=$PATH:$GOPATH/bin
```

### Installing Cloudflare's cfssl toolkit
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
Set Vault specific Environment Variables:
```
export VAULT_ADDR=https://127.0.0.1:8200
export VAULT_CACERT="certs/ca.pem"
```  

Ensure Vault client is installed. Then init Vault using a single key (DO NOT do this in production):
```
vault operator init -key-shares=1 -key-threshold=1
```

Take note of the unseal key and the initial root token. For example:
```
Unseal Key 1: F0Snz/ubK2IEdQ4a8WGECianyueTiIwsKAvV0XXYp4Y=

Initial Root Token: 8GIwICNI9Pn3dO9JFNnuUhTi
```

Unseal Vault:
```
$ vault operator unseal
Unseal Key (will be hidden): <paste Unseal Key 1>
```

Authenticate with the root token:
```
$ vault login
Token (will be hidden): <paste Initial Root Token>
```

Create a test secret:
```
$ vault kv put secret/precious mysecret=mysecretvalue

Success! Data written to: secret/precious
```

Read the test secret:
```
$ vault kv get secret/precious
=== Data ===
Key       Value
---       -----
mysecret  mysecretvalue
```

## Monitoring Your Cluster

To monitor this Kubernetes cluster, navigate to the [Grafana login page](http://localhost:3000). The default access credentials are:  
```
Username: admin
Password: prom-operator
```

A second method used for monitoring is to launch the Kubernetes dashboard. To run the dashboard, type the following command into your terminal:  
```
$ minikube dashboard
```

Your default web browser should launch and you should be immediately transported to the dashboard webpage.

## Tearing Everything Down
The easiest way to remove the `kubernetes-vault` cluster is to stop port-forwarding and then delete the whole works as follows:  
```
$ pkill kubectl
$ minikube delete
```

**HOWEVER**, if you just want to remove all of the Kubernetes resources and start over (without creating a new minikube cluster), then run the following:
```
$ make clean
```

Now you can run `make workstation` to re-deploy fresh Kubernetes resources again.
