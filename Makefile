SHELL = /bin/bash

all: certs

certs:
	./create_certs.sh

clean:
	rm -rfv certs
