SHELL = /bin/bash

.PHONY: workstation certs consul vault clean forward kubestart kubestop destroy

workstation: checklist certs consul vault forward

checklist:
	$(info Checking dependencies...)
	./checklist.sh

certs: 
	$(info Creating certificates...)
	./create_certs.sh

consul:  
	$(info Deploying Consul...)
	./deploy_consul.sh

vault: 
	$(info Deploying Vault...)
	./deploy_vault.sh

forward: 
	$(info Forwarding Vault port...)
	./port_forward.sh
	
clean:
	$(info Deleting certificates...)
	rm -rfv certs
	
destroy: clean
	$(info Destroying the cluster...)
	minikube delete
