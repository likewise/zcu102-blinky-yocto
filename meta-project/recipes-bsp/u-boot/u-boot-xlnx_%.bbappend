# configure the PMU firmware binary and the PMU configuration object
# currently still assuming it is externally provided for and deployed
do_configure_append() {
  cd ${B}
  sed -i 's,^CONFIG_DEFAULT_DEVICE_TREE.*,CONFIG_DEFAULT_DEVICE_TREE="zynqmp-zcu102-rev1.0",g' .config
  sed -i 's,^CONFIG_OF_LIST.*,CONFIG_OF_LIST="zynqmp-zcu102-rev1.0",g' .config
  sed -i 's,^CONFIG_PMUFW_INIT_FILE.*,CONFIG_PMUFW_INIT_FILE="${PMU_FIRMWARE_DEPLOY_DIR}/${PMU_FIRMWARE_IMAGE_NAME}.bin",g' .config
  sed -i 's,^CONFIG_ZYNQMP_SPL_PM_CFG_OBJ_FILE.*,CONFIG_ZYNQMP_SPL_PM_CFG_OBJ_FILE="${PMU_FIRMWARE_DEPLOY_DIR}/${PMU_CFG_OBJ_IMAGE_NAME}.bin",g' .config
  cp -aL ${DEPLOY_DIR_IMAGE}/bl31.bin ${B}
}

do_deploy_append() {
  install -D -m 644 ${B}/u-boot.itb ${DEPLOYDIR}/u-boot.itb
}

# after the configure stage, we want to make sure:
# ${B}/bl31.bin exists
# the above items appear in ${B}/.config
# the ps_init_gpl.{c|h} are copied across the board directories

# Solved by UBOOT_MACHINE = "xilinx_zynqmp_zcu102_rev1.1_defconfig"
#python () {
#        d.appendVar("EXTRA_OEMAKE", " DEVICE_TREE=\"zynqmp-zcu102-rev1.1\"")
#}

# This is plain wrong. HAS_PLATFORM_INIT has u-boot as subject, so in our case U-Boot
# does not have our platform init (psu_init_gpl.c), so this must NOT be set.
#HAS_PLATFORM_INIT_append = " xilinx_zynqmp_virt_config"

