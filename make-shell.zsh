#!/usr/bin/env zsh

set -o nomatch
set -o pipefail

local status() {
  echo -e "$@"
}

local pre_hook() {
  status "FONTSHIPPRE$target"
}

local post_hook() {
  status "FONTSHIPPOST$2$target"
}

local report_stdout() {
  cat - |
    while read line; do
      echo -e "FONTSHIPSTDOUT$target$line"
    done
}

local report_stderr() {
  cat - |
    while read line; do
      echo -e "FONTSHIPSTDERR$target$line" >&2
    done
}

local process_recipe() {
  pre_hook $target
  {
    (
      set -e
      [[ ! -v _debug ]] || set -x
      exec > >(report_stdout) 2> >(report_stderr)
      eval "$@"
    )
  } always {
    post_hook $target $?
  }
}

local process_shell() {
  (
    set -e
    [[ ! -v _debug ]] || set -x
    eval "$@"
  )
}

eval $1
shift

if [[ $1 = "+x" ]]; then
  _debug=true
  shift
fi

if [[ -n $target && -v MAKELEVEL ]]; then
  process_recipe $@
else
  process_shell $@
fi
