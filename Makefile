SHELL = /bin/bash

.PHONY: workstation certs consul vault clean destroy

workstation: deps certs consul vault

deps:
	./check_deps.sh

certs: 
	./create_certs.sh

consul:  
	./deploy_consul.sh

vault: 
	./deploy_vault.sh
	
clean:
	./cleanup.sh
	
destroy: clean
	minikube delete
