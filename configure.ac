AC_INIT([fontship],
        m4_esyscmd([build-aux/git-version-gen .tarball-version]),
        [caleb@alerque.com])
AM_INIT_AUTOMAKE([foreign dist-zip])
AM_SILENT_RULES([yes])

AC_CHECK_PROG(GFTOOLS, gftools, yes)
test "x$GFTOOLS" == "xyes" || AC_MSG_ERROR([gftools is required])

AC_CHECK_PROG(SFNT2WOFFZOPFLI, sfnt2woff-zopfli, yes)
test "x$SFNT2WOFFZOPFLI" == "xyes" || AC_MSG_ERROR([sfnt2woff-zopfli is required])

AC_CHECK_PROG(TTFAUTOHINT, ttfautohint, yes)
test "x$TTFAUTOHINT" == "xyes" || AC_MSG_ERROR([ttfautohint is required])

AC_CHECK_PROG(ZSH, zsh, yes)
test "x$ZSH" == "xyes" || AC_MSG_ERROR([zsh is required])

AM_PATH_PYTHON([3.6])

AC_CONFIG_FILES([Makefile])
AC_CONFIG_FILES([fontship], [chmod +x fontship])
AC_CONFIG_FILES([src/pre-commit.py], [chmod +x src/pre-commit.py])

AC_OUTPUT
