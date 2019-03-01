SHELL = /bin/bash

.PHONY: eks certs consul vault clean destroy

eks: deps

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
