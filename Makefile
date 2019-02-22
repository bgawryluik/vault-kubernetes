SHELL = /bin/bash

.PHONY: eks certs consul vault clean destroy

eks: deps

deps:
	$(info Checking dependencies...)
	./check_deps.sh

#certs: 
#	$(info Creating certificates...)
#	./create_certs.sh

#consul:  
#	$(info Deploying Consul...)
#	./deploy_consul.sh

#vault: 
#	$(info Deploying Vault...)
#	./deploy_vault.sh
	
#clean:
#	$(info Deleting certificates...)
#	rm -rfv certs
	
#destroy: clean
#	$(info Destroying the cluster...)
#	minikube delete
