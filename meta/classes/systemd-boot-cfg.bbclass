SYSTEMD_BOOT_CFG ?= "${S}/loader.conf"
SYSTEMD_BOOT_ENTRIES ?= ""
SYSTEMD_BOOT_TIMEOUT ?= "10"

# Uses MACHINE specific KERNEL_IMAGETYPE
PACKAGE_ARCH = "${MACHINE_ARCH}"

# Need UUID utility code.
inherit fs-uuid

python build_efi_cfg() {
    s = d.getVar("S")
    labels = d.getVar('LABELS')
    if not labels:
        bb.debug(1, "LABELS not defined, nothing to do")
        return

    if labels == []:
        bb.debug(1, "No labels, nothing to do")
        return

    #remove conf file from previous build
    files = os.listdir(s)
    for file in files:
        if file.endswith(".conf"):
            os.unlink(file)

    cfile = d.getVar('SYSTEMD_BOOT_CFG')
    cdir = os.path.dirname(cfile)
    if not os.path.exists(cdir):
        os.makedirs(cdir)
    try:
         cfgfile = open(cfile, 'w')
    except OSError:
        bb.fatal('Unable to open %s' % cfile)

    cfgfile.write('# Automatically created by OE\n')
    cfgfile.write('default %s\n' % (labels.split()[0]))
    timeout = d.getVar('SYSTEMD_BOOT_TIMEOUT')
    if timeout:
        cfgfile.write('timeout %s\n' % timeout)
    else:
        cfgfile.write('timeout 10\n')
    cfgfile.close()

    multi_boot_options = d.getVar('MULTI_BOOT_OPTIONS') if d.getVar('MULTI_BOOT_OPTIONS') else ""

    for label in labels.split():
        conf_count = 0
        for boot_option in multi_boot_options.split(';'):
            conf_title = "%s-%s" % ( label, conf_count) if boot_option else label
            localdata = d.createCopy()

            entryfile = "%s/%s.conf" % (s, conf_title)
            if not os.path.exists(s):
                os.makedirs(s)
            d.appendVar("SYSTEMD_BOOT_ENTRIES", " " + entryfile)
            try:
                entrycfg = open(entryfile, "w")
            except OSError:
                bb.fatal('Unable to open %s' % entryfile)

            entrycfg.write('title %s %s\n' % (conf_title, boot_option) )

            kernel = localdata.getVar("KERNEL_IMAGETYPE")
            entrycfg.write('linux /%s\n' % kernel)

            append = localdata.getVar('APPEND')
            initrd = localdata.getVar('INITRD')

            if initrd:
                entrycfg.write('initrd /initrd\n')
            lb = label
            if label == "install":
                lb = "install-efi"
            entrycfg.write('options LABEL=%s ' % lb)

            apd = append + boot_option
            if apd:
                apd = replace_rootfs_uuid(d, apd)
                entrycfg.write('%s' % apd)

            entrycfg.write('\n')
            entrycfg.close()
            conf_count += 1
}
