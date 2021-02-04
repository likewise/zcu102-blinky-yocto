.PHONY: all

.ONESHELL:
all: tmp tmp/deploy/images/zcu102-zynqmp/pmcfg.bin
	bitbake core-image-minimal-dev

# binutils to extract PMU configuration object
$(PWD)/tmp/sysroots-components/x86_64/binutils-cross-aarch64/usr/bin/aarch64-poky-linux/aarch64-poky-linux-objcopy:
	bitbake binutils-cross-aarch64

# PMU configuration object binary
tmp/deploy/images/zcu102-zynqmp/pmcfg.bin: $(PWD)/tmp/sysroots-components/x86_64/binutils-cross-aarch64/usr/bin/aarch64-poky-linux/aarch64-poky-linux-objcopy /tmp/zynqmp_fsbl.elf
	mkdir -vp $(shell dirname $@)
	$< -O binary -j ".sys_cfg_data" /tmp/zynqmp_fsbl.elf $@

# Pre-built FSBL (which contains linked-in PMU configuration object binary)
/tmp/zynqmp_fsbl.elf:
	tar -O -xvf ~/Downloads/xilinx-zcu102-v2020.2-final.bsp xilinx-zcu102-2020.2/pre-built/linux/images/zynqmp_fsbl.elf >build/tmp/deploy/images/zcu102-zynqmp/zynqmp_fsbl.elf

tmp:
	mkdir -p tmp
	sudo -n mount -t tmpfs tmpfs ./tmp || echo "Not mounting tmpfs on build/tmp"
