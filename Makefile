SHELL = /bin/bash

.PHONY: workstation certs monitoring consul vault clean destroy

workstation: deps certs monitoring consul vault

deps:
	./check_deps.sh

certs: 
	./create_certs.sh

monitoring:
	./deploy_monitoring.sh

consul:  
	./deploy_consul.sh

vault: 
	./deploy_vault.sh
	
clean:
	./cleanup.sh
	
destroy: clean
	minikube delete
