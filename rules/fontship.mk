# Defalut to running jobs in parallel, one for each CPU core
MAKEFLAGS += --jobs=$(shell nproc) --output-sync=target
# Default to not echoing commands before running
MAKEFLAGS += --silent
# Disable as much built in file type builds as possible
MAKEFLAGS += --no-builtin-rules
.SUFFIXES:

# Run recipies in zsh, and all in one pass
SHELL := zsh
.SHELLFLAGS := +o nomatch -e -c
.ONESHELL:
.SECONDEXPANSION:

# Don't drop intermediate artifacts (saves rebulid time and aids debugging)
.SECONDARY:
.PRECIOUS: %
.DELETE_ON_ERROR:

CONTAINERIZED != test -f /.dockerenv && echo true || echo false

# Initial environment setup
FONTSHIPDIR != cd "$(shell dirname $(lastword $(MAKEFILE_LIST)))/" && pwd
GITNAME := $(notdir $(or $(shell git remote get-url origin 2> /dev/null | sed 's,^.*/,,;s,.git$$,,' ||:),$(shell git worktree list | head -n1 | awk '{print $$1}')))
PROJECT ?= $(shell $(PYTHON) $(PYTHONFLAGS) -c 'import re; print(re.sub(r"[-_]", " ", "$(GITNAME)".title()).replace(" ", ""))')
_PROJECTDIR != cd "$(shell dirname $(firstword $(MAKEFILE_LIST)))/" && pwd
PROJECTDIR ?= $(_PROJECTDIR)
PUBDIR ?= $(PROJECTDIR)/pub
SOURCEDIR ?= sources

# Some Makefile shinanigans to avoid aggressive trimming
space := $() $()

# Allow overriding executables used
FONTMAKE ?= fontmake
FONTV ?= font-v
GFTOOLS ?= gftools
PYTHON ?= python3
SFNT2WOFF ?= sfnt2woff-zopfli
TTFAUTOHINT ?= ttfautohint
PSAUTOHINT ?= psautohint
SFDNORMALIZE ?= sfdnormalize
TTX ?= ttx
UFONORMALIZER ?= ufonormalizer
WOFF2COMPRESS ?= woff2_compress

BUILDDIR ?= .fontship

include $(FONTSHIPDIR)/functions.mk

.PHONY: default
default: all


