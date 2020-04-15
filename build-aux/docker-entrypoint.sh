#!/usr/bin/env sh

set -e

if [ "${1#-}" != "${1}" ] || [ -z "$(command -v "${1}")" ] || [ "${1}" == "make" ]; then
  set -- fontship "$@"
fi

exec "$@"
