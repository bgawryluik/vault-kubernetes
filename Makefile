SHELL = /bin/bash

.PHONY: workstation certs consul vault clean destroy

workstation: deps certs consul vault

deps:
	$(info Checking dependencies...)
	./check_deps.sh

certs: 
	$(info Creating certificates...)
	./create_certs.sh

consul:  
	$(info Deploying Consul...)
	./deploy_consul.sh

vault: 
	$(info Deploying Vault...)
	./deploy_vault.sh
	
clean:
	$(info Deleting certificates...)
	rm -rfv certs
	
destroy: clean
	$(info Destroying the cluster...)
	minikube delete
