FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

DEPENDS += "dtc-native"

SRC_URI += "file://boot.scr.its"

do_compile_append() {
  cp ${WORKDIR}/boot.cmd .
  mkimage -f ${WORKDIR}/boot.scr.its boot.scr.itb
}

do_deploy_append() {
    install -d ${DEPLOYDIR}
    install -m 0644 boot.scr.itb ${DEPLOYDIR}/${UBOOTSCR_BASE_NAME}.scr.itb
    ln -sf ${UBOOTSCR_BASE_NAME}.scr.itb ${DEPLOYDIR}/boot.scr.itb
}
