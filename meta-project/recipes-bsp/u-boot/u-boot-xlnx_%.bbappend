DEPENDS += "arm-trusted-firmware" 

# configure the PMU firmware binary, built via multiconfig for microblaze
# (somehow the EXTRA_OEMAKE provided setting does not end up in ${B}/.config (@TODO)

# configure the PMU configuration object, still must be externally provided. It is
# project dependent but the pre-built should work for the default projects:
#
# Fetch prebuilt First stage boot loader (FSBL) and extract PMU configuration object:
# tar -O -xvf ~/Downloads/xilinx-zcu102-v2020.2-final.bsp xilinx-zcu102-2020.2/pre-built/linux/images/zynqmp_fsbl.elf >/tmp/zynqmp_fsbl.elf
# build/tmp/sysroots-components/x86_64/binutils-cross-aarch64/usr/bin/aarch64-poky-linux/aarch64-poky-linux-objcopy \
#   -O binary -j ".sys_cfg_data" /tmp/zynqmp_fsbl.elf build/tmp/deploy/images/zcu102-zynqmp/pmcfg.bin
  
# Provide the ARM Trusted Firmware as bl31.bin
do_configure_append() {
  cd ${B}
  sed -i 's,^CONFIG_DEFAULT_DEVICE_TREE.*,CONFIG_DEFAULT_DEVICE_TREE="zynqmp-zcu102-rev1.0",g' .config
  sed -i 's,^CONFIG_OF_LIST.*,CONFIG_OF_LIST="zynqmp-zcu102-rev1.0",g' .config
  sed -i 's,^CONFIG_PMUFW_INIT_FILE.*,CONFIG_PMUFW_INIT_FILE="${PMU_FIRMWARE_DEPLOY_DIR}/${PMU_FIRMWARE_IMAGE_NAME}.bin",g' .config
  sed -i 's,^CONFIG_ZYNQMP_SPL_PM_CFG_OBJ_FILE.*,CONFIG_ZYNQMP_SPL_PM_CFG_OBJ_FILE="${TOPDIR}/tmp/deploy/images/${MACHINE}/${PMU_CFG_OBJ_IMAGE_NAME}.bin",g' .config

  cp -aL ${DEPLOY_DIR_IMAGE}/arm-trusted-firmware.bin ${B}/bl31.bin
}
# meta-xilinx/meta-xilinx-bsp/conf/machine/zynqmp-generic.conf
# hard-codes {TOPDIR}/tmp/deploy/images/${MACHINE}

do_deploy_append() {
  install -D -m 644 ${B}/u-boot.itb ${DEPLOYDIR}/u-boot.itb
}

# after the configure stage, we want to make sure:
# ${B}/bl31.bin exists
# the above items appear in ${B}/.config
# the ps_init_gpl.{c|h} are copied across the board directories

