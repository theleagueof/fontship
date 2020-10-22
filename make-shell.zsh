#!/usr/bin/env zsh

set +o nomatch

local fifo() {
  (
    [[ -v FONTSHIP_FIFO && -p $FONTSHIP_FIFO ]] && exec >> $FONTSHIP_FIFO
    echo $@
  )
}

local pre_hook() {
  fifo START $target
}

local post_hook() {
  fifo END $2 $target
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
