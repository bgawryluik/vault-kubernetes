SHELL = /bin/bash

.PHONY: workstation certs consul vault clean forward kubestart kubestop

workstation: certs consul vault

certs:
	$(info Creating certificates...)
	./create_certs.sh

consul: certs 
	$(info Deploying Consul...)
	./deploy_consul.sh

vault: consul
	$(info Deploying Vault...)
	./deploy_vault.sh

forward: vault
	$(info Forwarding Vault port...)
	./port_forward.sh
	
kubestop:
	$(info Stoping minikube...)
	minikube stop

kubestart:
	$(info Starting up minikube)
	minikube start --vm-driver=virtualbox

clean:
	$(info Deleting certificates...)
	rm -rfv certs
