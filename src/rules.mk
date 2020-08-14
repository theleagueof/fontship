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
GITNAME := $(notdir $(shell git worktree list | head -n1 | awk '{print $$1}'))
PROJECT ?= $(shell $(CONTAINERIZED) || $(PYTHON) $(PYTHONFLAGS) -c 'print("$(GITNAME)".replace(" ", "").title())')
_PROJECTDIR != cd "$(shell dirname $(firstword $(MAKEFILE_LIST)))/" && pwd
PROJECTDIR ?= $(_PROJECTDIR)
PUBDIR ?= $(PROJECTDIR)/pub
SOURCEDIR ?= sources

# Some Makefile shinanigans to avoid aggressive trimming
space := $() $()

SOURCES ?= $(shell git ls-files '$(SOURCEDIR)/*.glyphs' '$(SOURCEDIR)/*.sfd' '$(SOURCEDIR)/*.ufo')
CANONICAL ?= $(or $(and $(filter %.glyphs,$(SOURCES)),glyphs),\
			      $(and $(filter %.sfd,$(SOURCES)),sfd),\
			      $(and $(filter %.ufo,$(SOURCES)),ufo))

# Output format selectors
STATICOTF ?= true
STATICTTF ?= true
STATICWOFF ?= true
STATICWOFF2 ?= true
VARIABLEOTF ?=
VARIABLETTF ?= true
VARIABLEWOFF ?= true
VARIABLEWOFF2 ?= true

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
WOFF2COMPRESS ?= woff2_compress

include $(FONTSHIPDIR)/functions.mk

# Read font name from metadata file or guess from repository name
ifeq ($(CANONICAL),glyphs)
FamilyNames ?= $(foreach SOURCE,$(filter %.glyphs,$(SOURCES)),$(call glyphsFamilyNames,$(SOURCE)))
FontStyles ?= $(foreach SOURCE,$(filter %.glyphs),$(SOURCES)),$(call glyphsInstances,$(SOURCE)))
isVariable ?= true
endif

ifeq ($(CANONICAL),sfd)
FamilyNames ?= $(foreach SOURCE,$(filter %.sfd,$(SOURCES)),$(call sfdFamilyNames,$(SOURCE)))
# FontStyles = $(subst $(FontBase)-,,$(basename $(wildcard $(FontBase)-*.ufo)))
endif

ifeq ($(CANONICAL),ufo)
FamilyNames ?= $(foreach SOURCE,$(filter %.ufo,$(SOURCES)),$(call ufoFamilyNames,$(SOURCE)))
FontStyles ?= $(foreach SOURCE,$(filter %.ufo,$(SOURCES))),$(call ufoInstances,$(SOURCE)))
endif

FamilyName ?= $(shell $(CONTAINERIZED) || $(PYTHON) $(PYTHONFLAGS) -c 'print("$(PROJECT)".replace("-", " ").title())')

INSTANCES ?= $(foreach FamilyName,$(FamilyNames),$(foreach STYLE,$(FontStyles),$(BASE)-$(STYLE)))

GITVER = --tags --abbrev=6 --match='[0-9].[0-9][0-9][0-9]'
# Determine font version automatically from repository git tags
FontVersion ?= $(shell git describe $(GITVER) 2> /dev/null | sed 's/-.*//g')
ifneq ($(FontVersion),)
FontVersionMeta ?= $(shell git describe --always --long $(GITVER) | sed 's/-[0-9]\+/\\;/;s/-g/[/')]
GitVersion ?= $(shell git describe $(GITVER) | sed 's/-/-r/')
isTagged := $(if $(subst $(FontVersion),,$(GitVersion)),,true)
else
FontVersion = 0.000
FontVersionMeta ?= $(FontVersion)\;[$(shell git rev-parse --short=6 HEAD)]
GitVersion ?= $(FontVersion)-r$(shell git rev-list --count HEAD)-g$(shell git rev-parse --short=6 HEAD)
isTagged :=
endif

.PHONY: default
default: all

ifeq ($(DEBUG),true)
.SHELLFLAGS += +x
MAKEFLAGS += --no-silent
FONTMAKEFLAGS ?= --verbose DEBUG
FONTVFLAGS ?=
PSAUTOHINTFLAGS ?= -vv --traceback
TTFAUTOHINTFLAGS ?= -v --debug
TTXFLAGS ?= -v
WOFF2COMPRESSFLAGS ?=
GFTOOLSFLAGS ?=
PYTHONFLAGS ?= -d
SFNT2WOFFFLAGS ?=
else
ifeq ($(VERBOSE),true)
MAKEFLAGS += --no-silent
FONTMAKEFLAGS ?= --verbose INFO
FONTVFLAGS ?=
GFTOOLSFLAGS ?=
PSAUTOHINTFLAGS ?= -vv
PYTHONFLAGS ?= -v
SFNT2WOFFFLAGS ?=
TTFAUTOHINTFLAGS ?= -v
TTXFLAGS ?= -v
WOFF2COMPRESSFLAGS ?=
else
ifeq ($(QUIET),true)
FONTMAKEFLAGS ?= --verbose ERROR 2> /dev/null
FONTVFLAGS ?= 2> /dev/null
GFTOOLSFLAGS ?= > /dev/null
PSAUTOHINTFLAGS ?= 2> /dev/null
PYTHONFLAGS ?= 2> /dev/null
SFNT2WOFFFLAGS ?= 2> /dev/null
TTFAUTOHINTFLAGS ?= 2> /dev/null
TTXFLAGS ?= 2> /dev/null
WOFF2COMPRESSFLAGS ?= 2> /dev/null
else
FONTMAKEFLAGS ?= --verbose WARNING
FONTVFLAGS ?=
GFTOOLSFLAGS ?=
PSAUTOHINTFLAGS ?= -v
PYTHONFLAGS ?=
SFNT2WOFFFLAGS ?=
TTFAUTOHINTFLAGS ?=
TTXFLAGS ?=
WOFF2COMPRESSFLAGS ?=
endif
endif
endif

STATICOTFS = $(and $(STATICOTF),$(addsuffix .otf,$(INSTANCES)))
STATICTTFS = $(and $(STATICTTF),$(addsuffix .ttf,$(INSTANCES)))
STATICWOFFS = $(and $(STATICWOFF),$(addsuffix .woff,$(INSTANCES)))
STATICWOFF2S = $(and $(STATICWOFF2),$(addsuffix .woff2,$(INSTANCES)))
ifeq ($(isVariable),true)
VARIABLEOTFS = $(and $(VARIABLEOTF),$(addsuffix -VF.otf,$(FamilyNames)))
VARIABLETTFS = $(and $(VARIABLETTF),$(addsuffix -VF.ttf,$(FamilyNames)))
VARIABLEWOFFS = $(and $(VARIABLEWOFF),$(addsuffix -VF.woff,$(FamilyNames)))
VARIABLEWOFF2S = $(and $(VARIABLEWOFF2),$(addsuffix -VF.woff2,$(FamilyNames)))
endif

.PHONY: debug
debug:
	echo FONTSHIPDIR = $(FONTSHIPDIR)
	echo GITNAME = $(GITNAME)
	echo PROJECT = $(PROJECT)
	echo PROJECTDIR = $(PROJECTDIR)
	echo PUBDIR = $(PUBDIR)
	echo SOURCEDIR = $(SOURCEDIR)
	echo ----------------------------
	echo FamilyNames = $(FamilyNames)
	echo FontStyles = $(FontStyles)
	echo FontVersion = $(FontVersion)
	echo FontVersionMeta = $(FontVersionMeta)
	echo GitVersion = $(GitVersion)
	echo isTagged = $(isTagged)
	echo ----------------------------
	echo CANONICAL = $(CANONICAL)
	echo SOURCES = $(SOURCES)
	echo INSTANCES = $(INSTANCES)
	echo STATICOTFS = $(STATICOTFS)
	echo STATICTTFS = $(STATICTTFS)
	echo STATICWOFFS = $(STATICWOFFS)
	echo STATICWOFF2S = $(STATICWOFF2S)
	echo VARIABLEOTFS = $(VARIABLEOTFS)
	echo VARIABLETTFS = $(VARIABLETTFS)
	echo VARIABLEWOFFS = $(VARIABLEWOFFS)
	echo VARIABLEWOFF2S = $(VARIABLEWOFF2S)

.PHONY: _gha
_gha:
	echo "::set-output name=PROJECT::$(PROJECT)"
	echo "::set-output name=font-version::$(FontVersion)"
	echo "::set-output name=DISTDIR::$(DISTDIR)"

.PHONY: all
all: fonts $(and $(DEBUG),debug)

.PHONY: clean
clean:
	git clean -dxf

.PHONY: ufo
ufo: $$(addsuffix .ufo,$$(INSTANCES))

.PHONY: glyphs
glyphs: $$(addsuffix .glyphs,$$(INSTANCES))

.PHONY: sfd
sfd: $$(addsuffix .sfd,$$(INSTANCES))

.PHONY: fonts
fonts: static variable

.PHONY: static
static: static-otf static-ttf static-woff static-woff2

.PHONY: variable
variable: variable-otf variable-ttf variable-woff variable-woff2

.PHONY: otf
otf: static-otf variable-otf

.PHONY: ttf
ttf: static-ttf variable-ttf

.PHONY: woff
woff: static-woff variable-woff

.PHONY: woff2
woff2: static-woff2 variable-woff2

.PHONY: static-otf
static-otf: $$(STATICOTFS)

.PHONY: static-ttf
static-ttf: $$(STATICTTFS)

.PHONY: static-woff
static-woff: $$(STATICWOFFS)

.PHONY: static-woff2
static-woff2: $$(STATICWOFF2S)

.PHONY: variable-otf
variable-otf: $$(VARIABLEOTFS)

.PHONY: variable-ttf
variable-ttf: $$(VARIABLETTFS)

.PHONY: variable-woff
variable-woff: $$(VARIABLEWOFFS)

.PHONY: variable-woff2
variable-woff2: $$(VARIABLEWOFF2S)

.PHONY: normalize
normalize: $(filter %.glyphs %.sfd %.ufo,$(SOURCES))

.PHONY: check
check:

BUILDDIR ?= .fontship

$(BUILDDIR):
	mkdir -p $@

ifeq ($(PROJECT),data)
$(warning We cannot read the Project’s name inside Docker. Please manually specify it by adding PROOJECT='Name' as an agument to your command invocation)
endif

-include $(FONTSHIPDIR)/rules-$(CANONICAL).mk

$(foreach FamilyName,$(FamilyNames),$(eval $(call otf_instance_template,$(FamilyName))))
$(foreach FamilyName,$(FamilyNames),$(eval $(call ttf_instance_template,$(FamilyName))))

# Final steps common to all input formats

$(BUILDDIR)/%-hinted.ttf: $(BUILDDIR)/%-instance.ttf
	$(TTFAUTOHINT) $(TTFAUTOHINTFLAGS) -n $< $@

$(BUILDDIR)/%-hinted.ttf.fix: $(BUILDDIR)/%-hinted.ttf
	$(GFTOOLS) $(GFTOOLSFLAGS) fix-hinting $<

$(STATICTTFS): %.ttf: $(BUILDDIR)/%-hinted.ttf.fix $(BUILDDIR)/last-commit
	cp $< $@
	$(normalizeVersion)

$(BUILDDIR)/%-hinted.otf: $(BUILDDIR)/%-instance.otf
	$(PSAUTOHINT) $(PSAUTOHINTFLAGS) $< -o $@ --log $@.log

$(STATICOTFS): %.otf: $(BUILDDIR)/%-hinted.otf $(BUILDDIR)/last-commit
	cp $< $@
	$(normalizeVersion)

# Webfont compressions

%.woff: %.ttf
	$(SFNT2WOFF) $(SFNT2WOFFFLAGS) $<

%.woff2: %.ttf
	$(WOFF2COMPRESS) $(WOFF2COMPRESSFLAGS) $<

# Utility stuff

.PHONY: $(BUILDDIR)/last-commit
$(BUILDDIR)/last-commit: | $(BUILDDIR)
	git update-index --refresh --ignore-submodules ||:
	git diff-index --quiet --cached HEAD -- $(SOURCES)
	ts=$$(git log -n1 --pretty=format:%cI HEAD)
	touch -d "$$ts" -- $@

DISTDIR = $(PROJECT)-$(GitVersion)

$(DISTDIR):
	mkdir -p $@

.PHONY: dist
dist: $(DISTDIR).zip $(DISTDIR).tar.xz

$(DISTDIR).tar.bz2 $(DISTDIR).tar.gz $(DISTDIR).tar.xz $(DISTDIR).zip $(DISTDIR).tar.zst: install-dist
	bsdtar -acf $@ $(DISTDIR)

dist_doc_DATA ?= $(wildcard $(foreach B,readme README,$(foreach E,md txt markdown,$(B).$(E))))
dist_license_DATA ?= $(wildcard $(foreach B,ofl OFL ofl-faq OFL-FAQ license LICENSE copying COPYING,$(foreach E,md txt markdown,$(B).$(E))))

.PHONY: install-dist
install-dist: fonts | $(DISTDIR)
	$(and $(dist_doc_DATA),install -Dm644 -t "$(DISTDIR)/" $(dist_doc_DATA))
	$(and $(dist_license_DATA),install -Dm644 -t "$(DISTDIR)/" $(dist_license_DATA))
	$(and $(STATICOTFS),install -Dm644 -t "$(DISTDIR)/static/OTF/" $(STATICOTFS))
	$(and $(STATICTTFS),install -Dm644 -t "$(DISTDIR)/static/TTF/" $(STATICTTFS))
	$(and $(STATICWOFFS),install -Dm644 -t "$(DISTDIR)/static/WOFF/" $(STATICWOFFS))
	$(and $(STATICWOFF2S),install -Dm644 -t "$(DISTDIR)/static/WOFF2/" $(STATICWOFF2S))
	$(and $(VARIABLEOTFS),install -Dm644 -t "$(DISTDIR)/variable/OTF/" $(VARIABLEOTFS))
	$(and $(VARIABLETTFS),install -Dm644 -t "$(DISTDIR)/variable/TTF/" $(VARIABLETTFS))
	$(and $(VARIABLEWOFFS),install -Dm644 -t "$(DISTDIR)/variable/WOFF/" $(VARIABLEWOFFS))
	$(and $(VARIABLEWOFF2S),install -Dm644 -t "$(DISTDIR)/variable/WOFF2/" $(VARIABLEWOFF2S))

install-local: install-local-otf

install-local-otf: otf
	$(and $(STATICOTFS),install -Dm644 -t "$${HOME}/.local/share/fonts/OTF/" $(STATICOTFS))
	$(and $(VARIABLEOTFS),install -Dm644 -t "$${HOME}/.local/share/fonts/variable/" $(VARIABLEOTFS))

install-local-ttf: ttf
	$(and $(STATICTTFS),install -Dm644 -t "$${HOME}/.local/share/fonts/TTF/" $(STATICTTFS))
	$(and $(VARIABLETTFS),install -Dm644 -t "$${HOME}/.local/share/fonts/variable/" $(VARIABLETTFS))

# Empty recipie to suppres makefile regeneration
$(MAKEFILE_LIST):;

# Special dependency to force rebuilds of up to date targets
.PHONY: force
force:;
