#!/usr/bin/env sh
set -e

incomplete_source () {
    echo -e "$1. Please either:\n" \
            "* $2,\n" \
            "* or use the source packages instead of a repo archive\n" \
            "* or use a full Git clone.\n" >&2
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

autoreconf --install -W none
