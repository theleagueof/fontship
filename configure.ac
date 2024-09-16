AC_PREREQ([2.69])
AC_INIT([fontship], [m4_esyscmd(build-aux/git-version-gen .tarball-version)],[caleb@alerque.com])
AC_CONFIG_AUX_DIR([build-aux])
AC_CONFIG_MACRO_DIR([build-aux])
AM_INIT_AUTOMAKE([foreign tar-pax dist-zstd dist-zip no-dist-gzip color-tests subdir-objects])
AM_SILENT_RULES([yes])

# Load up re-usable m4 bits shared across Caleb's projects
QUE_GIT_VERSION
QUE_TRANSFORM_PACKAGE_NAME
QUE_DEVELOPER_MODE
QUE_DIST_CHECKSUMS

# Check for and set variables for tooling used during our build process
AC_PROG_AWK
AC_PROG_GREP
AC_PROG_SED
QUE_PROGVAR([cmp])
QUE_PROGVAR([find])
QUE_PROGVAR([jq])
QUE_PROGVAR([sort])
QUE_PROGVAR([xargs])

QUE_RUST_BOILERPLATE
QUE_DOCKER_BOILERPLATE

AC_ARG_ENABLE([dependency-checks],
              AS_HELP_STRING([--disable-dependency-checks],
                      [Disable build tooling dependency checks]))
AM_CONDITIONAL([DEPENDENCY_CHECKS], [test "x$enable_dependency_checks" != "xno"])


AM_COND_IF([DEPENDENCY_CHECKS], [

    # Run time deps
    AC_PROG_EGREP
    AC_PROG_INSTALL
    AC_PROG_MKDIR_P
    QUE_PROGVAR([babelfont])
    QUE_PROGVAR([fontmake])
    QUE_PROGVAR([fontv], [font-v])
    QUE_PROGVAR([gftools])
    QUE_PROGVAR([git])
    QUE_PROGVAR([psautohint])
    QUE_PROGVAR([sfdnormalize])
    QUE_PROGVAR([sfd2ufo])
    QUE_PROGVAR([sfnt2woffzopfli], [sfnt2woff-zopfli])
    QUE_PROGVAR([ttfautohint])
    QUE_PROGVAR([ttx])
    QUE_PROGVAR([ufonormalizer])
    QUE_PROGVAR([woff2_compress])
    QUE_PROGVAR([zsh])

    AM_PATH_PYTHON([3.6])
    AX_PYTHON_MODULE(cffsubr, true)
    AX_PYTHON_MODULE(defcon, true)
    AX_PYTHON_MODULE(pcpp, true)
    AX_PYTHON_MODULE(sfdLib, true)
    AX_PYTHON_MODULE(pathops, true)
    AX_PYTHON_MODULE(ufo2ft, true)
    AX_PYTHON_MODULE(ufoLib2, true)
    AX_PYTHON_MODULE(vttLib, true)

    # Developer tooling deps
    AM_COND_IF([DEVELOPER_MODE], [
        QUE_PROGVAR([checkmake])
        QUE_PROGVAR([docker])
        QUE_PROGVAR([npm])
        QUE_PROGVAR([ruff])
        QUE_PROGVAR([tr])
    ])
])

# Avoid the need for configuring with the `--datarootdir=$(cd ..; pwd)` hack to
# run from the source directory when developer mode is enabled.
AM_COND_IF([DEVELOPER_MODE], [
    datarootdir="$(cd ..; pwd)"
])

AC_CONFIG_FILES([Makefile])
AC_CONFIG_FILES([rules/fontship.mk])

AC_CONFIG_FILES([lib/make-shell.zsh], [chmod +x lib/make-shell.zsh])
AC_CONFIG_FILES([lib/fontship-entry.zsh], [chmod +x lib/fontship-entry.zsh])

AC_OUTPUT

# Avoid the perceived need to run automake again when building from source
# tarballs. The assorted AM include macros assume two passes are needed to
# generate a makefile since one pass has to generate the includes and the
# second one inlines them, but we're distributing a ready-to-use version and
# hence one pass is enough. We can skip ahead and assume the Makefile template
# is ready to go an this point, avoiding the need for autotools at all.
AM_COND_IF([SOURCE_IS_DIST], [touch -r aminclude.am Makefile.in])
