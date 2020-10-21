#!/usr/bin/env zsh

set +o nomatch

local pre_hook() {
  :
}

local post_hook() {
  :
}

local process_recipe() {
  pre_hook $target
  {
    ( set -e; eval $@ )
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
