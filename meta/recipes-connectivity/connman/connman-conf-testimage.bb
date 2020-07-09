DESCRIPTION = "This is the ConnMan configuration to set up a Wired \
network interface for a machine to run under qemu for testimage purpose."

include connman-conf.bb

FILESEXTRAPATHS_prepend := "${THISDIR}/connman-conf:"

SRC_URI_append = " file://wired.config \
                   file://wired-setup \
                   file://wired-connection.service \
"

SYSTEMD_SERVICE_${PN} = "wired-connection.service"
