# Hashicorp's Vault using Kubernetes
## Running Vault and Consul on Kubernetes
Based on the blog [post](https://testdriven.io/blog/running-vault-and-consul-on-kubernetes/) create by [Michael Herman](https://github.com/mjhea0).

**NOTE**: these instuctions assume that your workstation is a Mac. For example, this installation was tested on a 2017 MacBook (3.1GHz Intel Core I7 with 16GB of memory) running macOS Mojave (v10.14.2).

## Requirements
It is much easier to follow these instruction if you already have [Homebrew](https://brew.sh/) installed on your Mac. Click this [link](https://brew.sh/) for installation instructions.

| Requirement | My Version | Installation Instrunctions |
| ----------- | ------- | -------------------------- |
| [Docker](https://docs.docker.com/docker-for-mac/install/) | 18.09.1 | `brew install docker` |
| [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/) | Client Version: v1.13.2 | `brew install kubectl` |
| [minikube](https://kubernetes.io/docs/tasks/tools/install-minikube/) | v0.30.0 | `brew cask install virtualbox; brew cask install minikube` |
| Hashicorp [consul](https://www.consul.io/) client | v1.4.0 | `brew install consul` |
| Hashicorp [vault](https://www.vaultproject.io/) client| v1.0.2 | `brew install vault` |
| [Golang](https://golang.org/doc/install) | 1.11.5 | `brew install go --cross-compile-common` |

### Configuring Golang

Make certain that you remember to set you `GOPATH` variable.  

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


## Tearing Everything Down
The easiest way to remove the `kubernetes-vault` cluster is to stop port-forwarding and then delete the whole works as follows:  
```
$ pkill kubectl
$ minikube delete
```
