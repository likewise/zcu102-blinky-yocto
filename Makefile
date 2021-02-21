# Required for BitBake/Yocto
SHELL = /bin/bash

.ONESHELL:

.PHONY: all

all:
	source ./poky/oe-init-build-env build
	make
	# for old Make executables without ONESHELL support:
	# bash -c 'source ./poky/oe-init-build-env build && make'
