SHELL := /bin/bash

packer-validate:
	packer fmt .
	packer validate .

packer-build: packer-validate
	echo "packer build ."
