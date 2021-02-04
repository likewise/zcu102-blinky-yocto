# Required for BitBake/Yocto
SHELL = /bin/bash
.ONESHELL:

.PHONY: all prebuilt

all:
	source ./poky/oe-init-build-env build
	make
	# for old Make executables without ONESHELL support:
	# bash -c 'source ./poky/oe-init-build-env build && make'

# This is no longer used. See the build/Makefile for the remainder.
prebuilt:
	mkdir -p build/tmp/deploy/images/zcu102-zynqmp
	# PMU ROM
	tar -O -xvf ~/Downloads/xilinx-zcu102-v2020.2-final.bsp xilinx-zcu102-2020.2/pre-built/linux/images/pmu_rom_qemu_sha3.elf >build/tmp/deploy/images/zcu102-zynqmp/pmu-rom.elf
	# PMU Firmware
	tar -O -xvf ~/Downloads/xilinx-zcu102-v2020.2-final.bsp xilinx-zcu102-2020.2/pre-built/linux/images/pmufw.elf >build/tmp/deploy/images/zcu102-zynqmp/pmu-zcu102-zynqmp.elf
	# BL31 ARM Trusted Firmware (ATF)
	tar -O -xvf ~/Downloads/xilinx-zcu102-v2020.2-final.bsp xilinx-zcu102-2020.2/pre-built/linux/images/bl31.bin >build/tmp/deploy/images/zcu102-zynqmp/bl31.bin
	# First stage boot loader (FSBL)
	tar -O -xvf ~/Downloads/xilinx-zcu102-v2020.2-final.bsp xilinx-zcu102-2020.2/pre-built/linux/images/zynqmp_fsbl.elf >build/tmp/deploy/images/zcu102-zynqmp/zynqmp_fsbl.elf
	# build/tmp/sysroots-components/x86_64/binutils-cross-aarch64/usr/bin/aarch64-poky-linux/aarch64-poky-linux-objcopy
	objcopy -O binary -j ".sys_cfg_data" build/tmp/deploy/images/zcu102-zynqmp/zynqmp_fsbl.elf build/tmp/deploy/images/zcu102-zynqmp/pmcfg.bin
	# Device tree binary
	tar -O -xvf ~/Downloads/xilinx-zcu102-v2020.2-final.bsp xilinx-zcu102-2020.2/pre-built/linux/images/system.dtb >build/tmp/deploy/images/zcu102-zynqmp/system.dtb
