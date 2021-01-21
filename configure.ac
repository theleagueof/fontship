AC_INIT([fontship],[m4_esyscmd(build-aux/git-version-gen .tarball-version)],[caleb@alerque.com])
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
              AS_HELP_STRING([--enable-debug],[Build Rust code with debugging information [default=no]]),
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

AC_ARG_WITH([bash-completion-dir],
    AS_HELP_STRING([--with-bash-completion-dir[=PATH]],
        [Install the bash auto-completion script in this directory. @<:@default=yes@:>@]),
    [],
    [with_bash_completion_dir=yes])
if test "x$with_bash_completion_dir" = "xyes"; then
    PKG_CHECK_MODULES([BASH_COMPLETION], [bash-completion >= 2.0],
        [BASH_COMPLETION_DIR="`pkg-config --variable=completionsdir bash-completion`"],
        [BASH_COMPLETION_DIR="$datadir/bash-completion/completions"])
else
    BASH_COMPLETION_DIR="$with_bash_completion_dir"
fi
AC_SUBST([BASH_COMPLETION_DIR])
AM_CONDITIONAL([ENABLE_BASH_COMPLETION],[test "x$with_bash_completion_dir" != "xno"])

AC_ARG_WITH([fish-completion-dir],
    AS_HELP_STRING([--with-fish-completion-dir[=PATH]],
        [Install the fish auto-completion script in this directory. @<:@default=yes@:>@]),
    [],
    [with_fish_completion_dir=yes])
if test "x$with_fish_completion_dir" = "xyes"; then
    PKG_CHECK_MODULES([FISH_COMPLETION], [fish >= 3.0],
        [FISH_COMPLETION_DIR="`pkg-config --variable=completionsdir fish`"],
        [FISH_COMPLETION_DIR="$datadir/fish/vendor_completions.d"])
else
    FISH_COMPLETION_DIR="$with_fish_completion_dir"
fi
AC_SUBST([FISH_COMPLETION_DIR])
AM_CONDITIONAL([ENABLE_FISH_COMPLETION],[test "x$with_fish_completion_dir" != "xno"])

AC_ARG_WITH([zsh-completion-dir],
    AS_HELP_STRING([--with-zsh-completion-dir[=PATH]],
        [Install the zsh auto-completion script in this directory. @<:@default=yes@:>@]),
    [],
    [with_zsh_completion_dir=yes])
if test "x$with_zsh_completion_dir" = "xyes"; then
    ZSH_COMPLETION_DIR="$datadir/zsh/site-functions"
else
    ZSH_COMPLETION_DIR="$with_zsh_completion_dir"
fi
AC_SUBST([ZSH_COMPLETION_DIR])
AM_CONDITIONAL([ENABLE_ZSH_COMPLETION],[test "x$with_zsh_completion_dir" != "xno"])

AC_SUBST([RUST_TARGET_SUBDIR])

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
AC_CONFIG_FILES([rules/fontship.mk])

AC_ARG_PROGRAM

AC_OUTPUT
