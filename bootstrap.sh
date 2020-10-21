#!/usr/bin/env sh
set -e

incomplete_source () {
    echo "$1. Please either:" >&2
    echo "* $2," >&2
    echo '* or use the source packages instead of a repo archive' >&2
    echo '* or use a full Git clone.' >&2
    exit 1
}

# Hint how to build from Github's snapshot archives
if [ ! -e ".git" ]; then
    if [ ! -f ".tarball-version" ]; then
    incomplete_source "No version information found" \
        "identify the correct version with \`echo \$version > .tarball-version\`"
    fi
else
    # Save a ./configure cycle with a headstart for fresh clones
    ./build-aux/git-version-gen .tarball-version > .version
fi

autoreconf --symlink --install --warnings=none
aclocal --force -W none
automake --force-missing --add-missing -W none
