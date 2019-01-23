SHELL = /bin/bash

.PHONY: certs consul clean

all: certs consul

certs:
	./create_certs.sh

consul: certs 
	./deploy_consul.sh

clean:
	rm -rfv certs
