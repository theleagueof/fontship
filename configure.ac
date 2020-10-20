AC_INIT([fontship],
        m4_esyscmd([build-aux/git-version-gen .tarball-version]),
        [caleb@alerque.com])
AM_INIT_AUTOMAKE([foreign tar-pax dist-xz dist-zip no-dist-gzip color-tests])
AM_SILENT_RULES([yes])

# Check that we have rust stuff
AC_CHECK_PROG(CARGO, [cargo], [yes], [no])
AS_IF(test x$CARGO = xno,
    AC_MSG_ERROR([cargo is required.  Please install the Rust toolchain])
)
AC_CHECK_PROG(RUSTC, [rustc], [yes], [no])
AS_IF(test x$RUSTC = xno,
    AC_MSG_ERROR([rustc is required.  Please install the Rust toolchain])
)

# Add --enable-debug flag to change Rust build mode
AC_ARG_ENABLE(debug,
              AC_HELP_STRING([--enable-debug],
                             [Build Rust code with debugging information [default=no]]),
              [debug_release=$enableval],
              [debug_release=no])

AC_MSG_CHECKING(whether to build Rust code with debugging information)
if test "x$debug_release" = "xyes" ; then
    AC_MSG_RESULT(yes)
    RUST_TARGET_SUBDIR=debug
else
    AC_MSG_RESULT(no)
    RUST_TARGET_SUBDIR=release
fi
AM_CONDITIONAL([DEBUG_RELEASE], [test "x$debug_release" = "xyes"])

AC_CHECK_PROG(GFTOOLS, gftools, yes)
test "x$GFTOOLS" == "xyes" || AC_MSG_ERROR([gftools is required])

AC_CHECK_PROG(FONT_V, font-v, yes)
test "x$FONT_V" == "xyes" || AC_MSG_ERROR([font-v is required])

AC_CHECK_PROG(FONTMAKE, fontmake, yes)
test "x$FONTMAKE" == "xyes" || AC_MSG_ERROR([fontmake is required])

AC_CHECK_PROG(SFNT2WOFFZOPFLI, sfnt2woff-zopfli, yes)
test "x$SFNT2WOFFZOPFLI" == "xyes" || AC_MSG_ERROR([sfnt2woff-zopfli is required])

AC_CHECK_PROG(SFNT2WOFFZOPFLI, sfnt2woff-zopfli, yes)
test "x$SFNT2WOFFZOPFLI" == "xyes" || AC_MSG_ERROR([sfnt2woff-zopfli is required])

AC_CHECK_PROG(TTFAUTOHINT, ttfautohint, yes)
test "x$TTFAUTOHINT" == "xyes" || AC_MSG_ERROR([ttfautohint is required])

AC_CHECK_PROG(TTX, ttx, yes)
test "x$TTX" == "xyes" || AC_MSG_ERROR([ttx is required])

AC_CHECK_PROG(WOFF2_COMPRESS, woff2_compress, yes)
test "x$WOFF2_COMPRESS" == "xyes" || AC_MSG_ERROR([woff2_compress is required])

AC_CHECK_PROG(ZSH, zsh, yes)
test "x$ZSH" == "xyes" || AC_MSG_ERROR([zsh is required])

AM_PATH_PYTHON([3.6])

if [[ -d .git ]]; then
    MAN_DATE=$(git log -1 --format="%cd" --date=format:"%d %B %Y" -- fontship.1.in)
else
    MAN_DATE=$(date "+%d %B %Y")
fi
AC_SUBST([MAN_DATE])

AC_CONFIG_FILES([Makefile fontship.1])

AC_OUTPUT
