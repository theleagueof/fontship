AC_PREREQ([2.69])
AC_INIT([fontship],[m4_esyscmd(build-aux/git-version-gen .tarball-version)],[caleb@alerque.com])
AC_CONFIG_AUX_DIR([build-aux])
AC_CONFIG_MACRO_DIR([build-aux])
AM_INIT_AUTOMAKE([foreign tar-pax dist-xz dist-zip no-dist-gzip color-tests subdir-objects])
AM_SILENT_RULES([yes])

AC_DEFUN([AX_PROGVAR],
		 [
		  test -n "$m4_toupper($1)" || { AC_PATH_PROG(m4_toupper($1), m4_default($2,$1)) }
		  test -n "$m4_toupper($1)" || AC_MSG_ERROR([m4_default($2,$1) is required])
		 ])

AC_PROG_AWK
AC_PROG_SED
AC_PROG_GREP
AX_PROGVAR([cmp])
AX_PROGVAR([xargs])

AC_ARG_ENABLE([dependency-checks],
              AS_HELP_STRING([--disable-dependency-checks], [Disable dependency checks]))

AC_ARG_WITH([bash-completion-dir],
    AS_HELP_STRING([--with-bash-completion-dir[=PATH]],
        [Install the bash auto-completion script in this directory. @<:@default=yes@:>@]),
    [],
    [with_bash_completion_dir=yes])
if test "x$with_bash_completion_dir" = "xyes"; then
    PKG_CHECK_MODULES([BASH_COMPLETION], [bash-completion >= 2.0],
        [BASH_COMPLETION_DIR="`pkg-config --define-variable=datadir=$datadir --variable=completionsdir bash-completion`"],
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
        [FISH_COMPLETION_DIR="`pkg-config --define-variable=datadir=$datadir --variable=completionsdir fish`"],
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

AS_IF([test "x$enable_dependency_checks" != "xno"], [
       AX_PROGVAR([cargo])
       AX_PROGVAR([rustc])
       AX_PROGVAR([jq])
       AX_PROGVAR([babelfont])
       AX_PROGVAR([find])
       AX_PROGVAR([fontmake])
       AX_PROGVAR([fontv], [font-v])
       AX_PROGVAR([gftools])
       AX_PROGVAR([git])
       AX_PROGVAR([psautohint])
       AX_PROGVAR([sfdnormalize])
       AX_PROGVAR([sfnt2woffzopfli], [sfnt2woff-zopfli])
       AX_PROGVAR([ttfautohint])
       AX_PROGVAR([ttx])
       AX_PROGVAR([ufonormalizer])
       AX_PROGVAR([woff2_compress])
       AX_PROGVAR([zsh])

       AM_PATH_PYTHON([3.6])
       AX_PYTHON_MODULE(cffsubr, true)
       AX_PYTHON_MODULE(defcon, true)
       AX_PYTHON_MODULE(pcpp, true)
       AX_PYTHON_MODULE(sfdLib, true)
       AX_PYTHON_MODULE(pathops, true)
       AX_PYTHON_MODULE(ufo2ft, true)
       AX_PYTHON_MODULE(ufoLib2, true)
       AX_PYTHON_MODULE(vttLib, true)
       ])

if [[ -d .git ]]; then
    MAN_DATE=$(git log -1 --format="%cd" --date=format:"%d %B %Y" -- fontship.1.in)
else
    MAN_DATE=$(date "+%d %B %Y")
fi
AC_SUBST([MAN_DATE])

TRANSFORMED_PACKAGE_NAME="$(printf "$PACKAGE_NAME" | $SED -e "${program_transform_name//\$\$/\$}")"
AC_SUBST([TRANSFORMED_PACKAGE_NAME])

AC_CONFIG_FILES([Makefile])
AC_CONFIG_FILES([fontship.1])
AC_CONFIG_FILES([rules/fontship.mk])
AC_CONFIG_FILES([make-shell.zsh], [chmod +x make-shell.zsh])

AC_ARG_PROGRAM

AC_OUTPUT
