# Defalut to running jobs in parallel, one for each CPU core
MAKEFLAGS += --jobs=$(shell nproc) --output-sync=none
# Default to not echoing commands before running
MAKEFLAGS += --silent
# Disable as much built in file type builds as possible
MAKEFLAGS += --no-builtin-rules
.SUFFIXES:

# Don't drop intermediate artifacts (saves rebulid time and aids debugging)
.SECONDARY:
.PRECIOUS: %
.DELETE_ON_ERROR:

CONTAINERIZED != test -f /.dockerenv && echo true || echo false

# Deprecate direct usage under `make` without the CLI
ifeq ($(FONTSHIP_CLI),)
$(error Use of fontship rule file inclusion outside of the CLI is deprecated!)
endif

# Initial environment setup
FONTSHIPDIR != cd "$(shell dirname $(lastword $(MAKEFILE_LIST)))/../" && pwd
GITNAME := $(notdir $(or $(shell git remote get-url origin 2> /dev/null | sed 's,^.*/,,;s,.git$$,,' ||:),$(shell git worktree list | head -n1 | awk '{print $$1}')))
PROJECT ?= $(shell $(PYTHON) $(PYTHONFLAGS) -c 'import re; print(re.sub(r"[-_]", " ", "$(GITNAME)".title()).replace(" ", ""))')
_PROJECTDIR != pwd
PROJECTDIR ?= $(_PROJECTDIR)
PUBDIR ?= $(PROJECTDIR)/pub
SOURCEDIR ?= sources

# Run recipies in zsh wrapper, and all in one pass
SHELL := $(FONTSHIPDIR)/make-shell.zsh
.SHELLFLAGS = target=$@
.ONESHELL:
.SECONDEXPANSION:

# Some Makefile shinanigans to avoid aggressive trimming
space := $() $()
lparen := (
rparen := )

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

include $(FONTSHIPDIR)/rules/functions.mk

.PHONY: default
default: all


