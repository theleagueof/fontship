#!/usr/bin/env sh
set -e

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
