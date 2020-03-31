AC_INIT([fontship],
        m4_esyscmd([build-aux/git-version-gen .tarball-version]),
        [caleb@alerque.com])
AM_INIT_AUTOMAKE([foreign dist-zip])
AM_SILENT_RULES([yes])

AM_PATH_PYTHON([3.6])

AC_CONFIG_FILES([Makefile])
AC_CONFIG_FILES([fontship], [chmod +x fontship])

AC_OUTPUT
