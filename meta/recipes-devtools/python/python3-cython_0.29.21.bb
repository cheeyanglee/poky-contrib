inherit setuptools3
require python-cython.inc

RDEPENDS_${PN} += "\
    python3-setuptools \
"

# running build_ext a second time during install fails, because Python
# would then attempt to import cythonized modules built for the target
# architecture.
DISTUTILS_INSTALL_ARGS += "--skip-build"

# remove WORKDIR info while compiling the generated .c code 
# to improve reproducibility
CC_append += " -fdebug-prefix-map=${WORKDIR}=  "

do_compile_append() {
    # these .c code are generate and compile at same steps, remove WORKDIR  
    # info from generated .c code to improve -src package reproducibility
    sed -i 's#${WORKDIR}##g' ${S}/Cython/*/*.c
}

do_install_append() {
    # rename scripts that would conflict with the Python 2 build of Cython
    mv ${D}${bindir}/cython ${D}${bindir}/cython3
    mv ${D}${bindir}/cythonize ${D}${bindir}/cythonize3
    mv ${D}${bindir}/cygdb ${D}${bindir}/cygdb3

    # remove WORKDIR info from SOURCES to improve  reproducibility
    sed -i 's#${WORKDIR}#/#g' ${D}${PYTHON_SITEPACKAGES_DIR}/Cython-*-info/SOURCES.txt
}
