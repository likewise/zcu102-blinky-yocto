all:
	

prebuilt:
	tar -O -xvf ~/Downloads/xilinx-zcu102-v2020.2-final.bsp xilinx-zcu102-2020.2/pre-built/linux/images/pmufw.elf >build/tmp/deploy/images/zcu102-zynqmp/pmu-zcu102-zynqmp.elf
	tar -O -xvf ~/Downloads/xilinx-zcu102-v2020.2-final.bsp xilinx-zcu102-2020.2/pre-built/linux/images/pmu_rom_qemu_sha3.elf >build/tmp/deploy/images/zcu102-zynqmp/pmu-rom.elf
	tar -O -xvf ~/Downloads/xilinx-zcu102-v2020.2-final.bsp xilinx-zcu102-2020.2/pre-built/linux/images/system.dtb >build/tmp/deploy/images/zcu102-zynqmp/system.dtb

pm_cfg_obj:
	cp -aL ~/sandbox/parretto/zcu102/pm_cfg_obj.S \
	/home/leon/sandbox/parretto/zcu102/build/tmp/work/zcu102_zynqmp-poky-linux/u-boot/1_2020.07-r0/git/board/xilinx/zynqmp/pm_cfg_obj.S

BUILD_DIR=${PWD}/build

# Required for BitBake/Yocto
SHELL = /bin/bash

# default target if you run make (note: excludes sdk target)
all: test-image production-image engineering-image audio-image

.PHONY: core-image-minimal recovery-image test-image engineering-image production-image audio-image

# full disk (USB/eMMC) images, audio.image is the final smarc.img to be put on Neuron
.ONESHELL:
recovery-image test-image engineering-image production-image audio-image:
	@ set -eu
	# source the Yocto environment in a new Bash shell, in build/ and run make target there
	bash -c '. ./poky/oe-init-build-env build && make $@'

# Build the SDK that is specific for the audio image
.ONESHELL:
sdk:
	@ set -eu
	@ echo "Building SDK"
	bash -c '. ./poky/oe-init-build-env build && bitbake audio-initramfs -c populate_sdk'

# Pack the built sdk
# .ONESHELL:
pack-sdk: sdk
	@ echo "Packing SDK"
	@ tar -czf "${BUILD_DIR}/smarc-audio-sdk-musl-$(shell git describe --match "[0-9]*.[0-9]*.[0-9]*" --always).tar.gz" \
	--owner=0 --group=0 --numeric-owner -C ${BUILD_DIR}/tmp-musl/ deploy/sdk

# Install the SDK, might need root permissions (use 'sudo make sdk-install' then)
.ONESHELL:
sdk-install:
	rm -rf /opt/smarc-sdk-musl
	./build/tmp-musl/deploy/sdk/oecore-x86_64-corei7-64-toolchain-nodistro.0.sh -d /opt/smarc-sdk-musl -y

# current Qt MV GPU PoC lives in core-image-minimal, packages in local.conf
core-image-minimal:
	bash -c '. ./poky/oe-init-build-env build && bitbake $@'

.PHONY: submodules
submodules:
	git submodule update --init --recursive

# DEVELOPMENT

.PHONY: deploy development release development-backup

# build and deploy audio.img to Neuron smarc.img via SSH/SCP and reboot Neuron
./ONESHELL:
deploy:
	# replace "leon", this is your Neuron hostname in .ssh/config
	make audio-image || exit
	ssh leon mount -o remount,rw /neuron/app
	scp build/audio.img leon:/neuron/app/smarc.img
	ssh leon mount -o remount,ro /neuron/app
	ssh leon /sbin/reboot

# make development will configure the image to include tools for development
.ONESHELL:
development: development-backup
	ln -snf development-setup.inc.linkme build/conf/development-setup.inc

# make release: undoes "make development"
.ONESHELL:
release: development-backup
	rm -f build/conf/development-setup.inc

.ONESHELL:
development-backup:
	[ -f build/conf/development-setup.inc ] && \
	[ ! -L build/conf/development-setup.inc ] && \
	mv build/conf/development-setup.inc `mktemp -p ./build/conf/ development-setup.inc.XXXXXX` && \
	echo "Backing up development-setup.inc as it seems a custom setup, not a link." || \
	true

.PHONY: serve-sstate
# Shares the built shared state using a HTTP server, for other developers to re-use pre-built results
serve-sstate:
	# Create directory for serving out the shared state
	mkdir -p served-state
	# Create a hard-link farm to shared state cache files
	cp -fRl build/sstate-cache/* served-state/
	# Download a single-binary HTTP server
	[ -f caddy ] || curl "https://caddyserver.com/download/linux/amd64?license=personal&telemetry=off" | tar xvz caddy
	# Kill previous HTTP server instance for shared state
	[ -f /tmp/smarc-caddy-2055.pid ] && kill -9 `cat /tmp/smarc-caddy-2055.pid`; rm -f /tmp/smarc-caddy-2055.pid /tmp/smarc-caddy-2055.log
	# Start HTTP server instance for shared state
	./caddy -root ./served-state -port 2055 -pidfile /tmp/smarc-caddy-2055.pid -log /tmp/smarc-caddy-2055.log &
