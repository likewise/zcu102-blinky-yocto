BUILD_DIR = ${PWD}/build

# Required for BitBake/Yocto
SHELL = /bin/bash

.PHONY: all prebuilt

.ONESHELL:
all: prebuilt
	cd $(BUILD_DIR)
	bash -c '. ./poky/oe-init-build-env build && bitbake core-image-minimal'

# Mount build/tmp on a RAM filesystem
build/tmp:
	cd $(BUILD_DIR)
	sudo mount -t tmpfs tmpfs ./tmp

build/tmp/sysroots-components/x86_64/binutils-cross-aarch64/usr/bin/aarch64-poky-linux/aarch64-poky-linux-objcopy:
	cd $(BUILD_DIR)
	bash -c '. ./poky/oe-init-build-env build && bitbake binutils-native'

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

	# build/tmp/sysroots-components/x86_64/binutils-cross-aarch64/usr/bin/aarch64-poky-linux/aarch64-poky-linux-objdump

pm_cfg_obj:
	cp -aL ~/sandbox/parretto/zcu102/pm_cfg_obj.S \
	/home/leon/sandbox/parretto/zcu102/build/tmp/work/zcu102_zynqmp-poky-linux/u-boot/1_2020.07-r0/git/board/xilinx/zynqmp/pm_cfg_obj.S
