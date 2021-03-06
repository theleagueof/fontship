AC_INIT([fontship],[m4_esyscmd(build-aux/git-version-gen .tarball-version)],[caleb@alerque.com])
AM_INIT_AUTOMAKE([foreign tar-pax dist-xz dist-zip no-dist-gzip subdir-objects color-tests])
AM_SILENT_RULES([yes])

AC_CONFIG_MACRO_DIRS([build-aux])

AC_ARG_ENABLE([dependency-checks],
              AS_HELP_STRING([--disable-dependency-checks], [Disable dependency checks]))

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

AC_SUBST([RUST_TARGET_SUBDIR])

AC_DEFUN([AX_PROGVAR], [AC_PATH_PROG(m4_toupper($1), m4_default($2,$1))test -n "$m4_toupper($1)" || AC_MSG_ERROR([m4_default($2,$1) is required])])

AS_IF([test "x$enable_dependency_checks" != "xno"], [

    # Check that we have rust stuff
    AC_CHECK_PROG(CARGO, [cargo], [yes], [no])
    AS_IF(test x$CARGO = xno,
        AC_MSG_ERROR([cargo is required.  Please install the Rust toolchain])
    )
    AC_CHECK_PROG(RUSTC, [rustc], [yes], [no])
    AS_IF(test x$RUSTC = xno,
        AC_MSG_ERROR([rustc is required.  Please install the Rust toolchain])
    )

    AC_PROG_SED
    AC_PROG_GREP

    AX_PROGVAR([cmp])
    AX_PROGVAR([fontv], [font-v])
    AX_PROGVAR([fontmake])
    AX_PROGVAR([gftools])
    AX_PROGVAR([find])
    AX_PROGVAR([git])
    AX_PROGVAR([sfnt2woffzopfli], [sfnt2woff-zopfli])
    AX_PROGVAR([ttfautohint])
    AX_PROGVAR([ufonormalizer])
    AX_PROGVAR([sfdnormalize])
    AX_PROGVAR([psautohint])
    AX_PROGVAR([ttx])
    AX_PROGVAR([woff2_compress])
    AX_PROGVAR([zsh])

    AM_PATH_PYTHON([3.6])
])

if [[ -d .git ]]; then
    MAN_DATE=$(git log -1 --format="%cd" --date=format:"%d %B %Y" -- fontship.1.in)
else
    MAN_DATE=$(date "+%d %B %Y")
fi
AC_SUBST([MAN_DATE])

AC_CONFIG_FILES([Makefile fontship.1])
AC_CONFIG_FILES([rules/fontship.mk])
AC_CONFIG_FILES([make-shell.zsh], [chmod +x make-shell.zsh])

AC_ARG_PROGRAM

AC_OUTPUT
