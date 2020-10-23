#!/usr/bin/env zsh

set -o nomatch
set -o pipefail

local status() {
  echo -e "$@"
}

local pre_hook() {
  status "FONTSHIPSTART$target"
}

local post_hook() {
  status "FONTSHIPEND$2$target"
}

local process_recipe() {
  pre_hook $target
  {
    (
      set -e
      eval $@ |
        while read line; do
          echo -e "FONTSHIPLINES$target$line"
        done
    )
  } always {
    post_hook $target $?
  }
}

local process_shell() {
  ( set -e; eval $@ )
}

eval $1
shift
if [[ -n $target && -v MAKELEVEL ]]; then
  process_recipe $@
else
  process_shell $@
fi
