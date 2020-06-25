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

CONTAINERIZED != test -f /.dockerenv && echo true || echo false

# Initial environment setup
FONTSHIPDIR != cd "$(shell dirname $(lastword $(MAKEFILE_LIST)))/" && pwd
GITNAME := $(notdir $(shell git worktree list | head -n1 | awk '{print $$1}'))
PROJECT ?= $(GITNAME)
_PROJECTDIR != cd "$(shell dirname $(firstword $(MAKEFILE_LIST)))/" && pwd
PROJECTDIR ?= $(_PROJECTDIR)
PUBDIR ?= $(PROJECTDIR)/pub
# Some Makefile shinanigans to avoid aggressive trimming
space := $() $()

CANONICAL ?= $(shell git ls-files | grep -q '\.glyphs$'' && echo glyphs || echo ufo)

# Allow overriding executables used
FONTMAKE ?= fontmake
FONT-V ?= font-v
GFTOOLS ?= gftools
PYTHON ?= python3
SFNT2WOFF ?= sfnt2woff-zopfli
TTFAUTOHINT ?= ttfautohint
TTX ?= ttx
WOFF2_COMPRESS ?= woff2_compress

include $(FONTSHIPDIR)/functions.mk

# Read font name from metadata file or guess from repository name
ifeq ($(CANONICAL),glyphs)
FamilyName = $(call familyName,$(firstword $(wildcard *.glyphs)))
endif

FamilyName ?= $(shell $(CONTAINERIZED) || $(PYTHON) -c 'print("$(PROJECT)".replace("-", " ").title())')

ifeq ($(FamilyName),)
$(error We cannot properly detect the font’s Family Name yet from inside Docker. Please manually specify it by adding FamilyName='Family Name' as an agument to your command invocation)
endif

GITVER = --tags --abbrev=6 --match='[0-9].[0-9][0-9][0-9]'
# Determine font version automatically from repository git tags
FontVersion ?= $(shell git describe $(GITVER) | sed 's/-.*//g')
FontVersionMeta ?= $(shell git describe --long $(GITVER) | sed 's/-[0-9]\+/\\;/;s/-g/[/')]
GitVersion ?= $(shell git describe $(GITVER) | sed 's/-/-r/')
isTagged := $(if $(subst $(FontVersion),,$(GitVersion)),,true)

# Look for what fonts & styles are in this repository that will need building
FontBase = $(subst $(space),,$(FamilyName))
FontStyles = $(subst $(FontBase)-,,$(basename $(wildcard $(FontBase)-*.ufo)))
FontStyles += $(foreach GLYPHS,$(wildcard $(FontBase).glyphs),$(call glyphWeights,$(GLYPHS)))

INSTANCES = $(foreach BASE,$(FontBase),$(foreach STYLE,$(FontStyles),$(BASE)-$(STYLE)))

STATICOTFS = $(addsuffix .otf,$(INSTANCES))
STATICTTFS = $(addsuffix .ttf,$(INSTANCES))
STATICWOFFS = $(addsuffix .woff,$(INSTANCES))
STATICWOFF2S = $(addsuffix .woff2,$(INSTANCES))
VARIABLEOTFS = $(addsuffix -VF.otf,$(FontBase))
VARIABLETTFS = $(addsuffix -VF.ttf,$(FontBase))
VARIABLEWOFFS = $(addsuffix -VF.woff,$(FontBase))
VARIABLEWOFF2S = $(addsuffix -VF.woff2,$(FontBase))

_FONTMAKEFLAGS = --master-dir '{tmp}' --instance-dir '{tmp}'
ifeq ($(DEBUG)),true)
FONTMAKEFLAGS ?= $(_FONTMAKEFLAGS) --verbose INFO
TTXFLAGS = -v
TTFAUTOHINTFLAGS = -v --debug
else
ifeq ($(VERBOSE)),true)
FONTMAKEFLAGS ?= $(_FONTMAKEFLAGS) --verbose WARNING
TTXFLAGS = -v
TTFAUTOHINTFLAGS = -v
else
FONTMAKEFLAGS ?= $(_FONTMAKEFLAGS) --verbose ERROR
TTXFLAGS ?=
TTFAUTOHINTFLAGS ?=
endif
endif

.PHONY: default
default: all

.PHONY: debug
debug:
	echo FONTSHIPDIR = $(FONTSHIPDIR)
	echo GITNAME = $(GITNAME)
	echo PROJECT = $(PROJECT)
	echo PROJECTDIR = $(PROJECTDIR)
	echo PUBDIR = $(PUBDIR)
	echo ----------------------------
	echo FamilyName = $(FamilyName)
	echo FontBase: $(FontBase)
	echo FontStyles: $(FontStyles)
	echo FontVersion: $(FontVersion)
	echo FontVersionMeta: $(FontVersionMeta)
	echo GitVersion: $(GitVersion)
	echo isTagged: $(isTagged)
	echo ----------------------------
	echo INSTANCES: $(INSTANCES)
	echo STATICOTFS: $(STATICOTFS)
	echo STATICTTFS: $(STATICTTFS)
	echo STATICWOFFS: $(STATICWOFFS)
	echo STATICWOFF2S: $(STATICWOFF2S)
	echo VARIABLEOTFS: $(VARIABLEOTFS)
	echo VARIABLETTFS: $(VARIABLETTFS)
	echo VARIABLEWOFFS: $(VARIABLEWOFFS)
	echo VARIABLEWOFF2S: $(VARIABLEWOFF2S)

.PHONY: _gha
_gha:
	echo "::set-output name=family-name::$(FamilyName)"
	echo "::set-output name=font-version::$(FontVersion)"
	echo "::set-output name=DISTDIR::$(DISTDIR)"

.PHONY: all
all: debug fonts

.PHONY: clean
clean:
	git clean -dxf

.PHONY: glyphs
glyphs: $$(addsuffix .glyphs,$$(INSTANCES))

.PHONY: fontforge
fontforge: $$(addsuffix .sfd,$$(INSTANCES))

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

ifeq ($(CANONICAL),glyphs)

%.glyphs: %.ufo
	$(FONTMAKE) $(FONTMAKEFLAGS) -u $< -o glyphs --output-path $@

# %.ufo: %.glyphs
#     $(FONTMAKE) -g $< -o ufo $(FONTMAKEFLAGS)

%.designspace: %.glyphs
	echo MM $@

endif

ifeq ($(CANONICAL),ufo)

%.sfd: %.ufo
	echo SDF: $@

# UFO normalize

%.ufo: .last-commit
	cat <<- EOF | $(PYTHON)
		from defcon import Font, Info
		ufo = Font('$@')
		major, minor = "$(FontVersion)".split(".")
		ufo.info.versionMajor, ufo.info.versionMinor = int(major), int(minor) + 7
		ufo.save('$@')
	EOF

endif

# UFO -> OTF

%.otf: %.ufo .last-commit
	cat <<- EOF | $(PYTHON)
		from ufo2ft import compileOTF
		from defcon import Font
		ufo = Font('$<')
		otf = compileOTF(ufo)
		otf.save('$@')
	EOF
	$(normalizeVersion)

# UFO -> TTF

%.ttf: %.ufo .last-commit
	cat <<- EOF | $(PYTHON)
		from ufo2ft import compileTTF
		from defcon import Font
		ufo = Font('$<')
		ttf = compileTTF(ufo)
		ttf.save('$@')
	EOF
	$(normalizeVersion)

# Glyphs -> Varibale OTF

%-VF-variable.otf: %.glyphs
	$(FONTMAKE) $(FONTMAKEFLAGS) -g $< -o variable-cff2 --output-path $@

$(VARIABLEOTFS): %.otf: %-variable.otf .last-commit
	cp $< $@
	$(normalizeVersion)

# Glyphs -> Varibale TTF

%-VF-variable.ttf: %.glyphs
	$(FONTMAKE) $(FONTMAKEFLAGS) -g $< -o variable --output-path $@
	$(GFTOOLS) fix-dsig --autofix $@

%-unhinted.ttf: %-variable.ttf
	$(GFTOOLS) fix-nonhinting $< $@

%-nomvar.ttx: %.ttf
	$(TTX) $(TTXFLAGS) -o $@ -f -x "MVAR" $<

%.ttf: %.ttx
	$(TTX) $(TTXFLAGS) -o $@ $<

$(VARIABLETTFS): %.ttf: %-unhinted-nomvar.ttf .last-commit
	cp $< $@
	$(normalizeVersion)

# Glyphs -> Static OTF

$(FontBase)-%-instance.otf: $(FontBase).glyphs
	$(FONTMAKE) $(FONTMAKEFLAGS) -g $< -i "$(FamilyName) $*" -o otf --output-path $@

$(STATICOTFS): %.otf: %-instance.otf .last-commit
	cp $< $@
	$(normalizeVersion)

# Glyphs -> Static TTF

$(FontBase)-%-instance.ttf: $(FontBase).glyphs
	$(FONTMAKE) $(FONTMAKEFLAGS) -g $< -i "$(FamilyName) $*" -o ttf --output-path $@
	$(GFTOOLS) fix-dsig --autofix $@

$(STATICTTFS): %.ttf: %-instance.ttf .last-commit
	$(TTFAUTOHINT) $(TTFAUTOHINTFLAGS) -n $< $@
	$(normalizeVersion)

# Webfont compressions

%.woff: %.ttf
	$(SFNT2WOFF) $<

%.woff2: %.ttf
	$(WOFF2_COMPRESS) $<

# Utility stuff

.PHONY: .last-commit
.last-commit:
	git update-index --refresh --ignore-submodules ||:
	git diff-index --quiet --cached HEAD -- *.ufo
	ts=$$(git log -n1 --pretty=format:%cI HEAD)
	touch -d "$$ts" -- $@

DISTDIR = $(FontBase)-$(GitVersion)

$(DISTDIR):
	mkdir -p $@

.PHONY: dist
dist: $(DISTDIR).zip $(DISTDIR).tar.bz2

$(DISTDIR).tar.bz2 $(DISTDIR).zip: install-dist
	bsdtar -acf $@ $(DISTDIR)

dist_doc_DATA ?= $(wildcard $(foreach B,readme README,$(foreach E,md txt markdown,$(B).$(E))))
dist_license_DATA ?= $(wildcard $(foreach B,ofl OFL ofl-faq OFL-FAQ license LICENSE copying COPYING,$(foreach E,md txt markdown,$(B).$(E))))

.PHONY: install-dist
install-dist: fonts $(DISTDIR)
	install -Dm644 -t "$(DISTDIR)/" $(dist_doc_DATA)
	install -Dm644 -t "$(DISTDIR)/" $(dist_license_DATA)
	install -Dm644 -t "$(DISTDIR)/static/OTF/" $(STATICOTFS)
	install -Dm644 -t "$(DISTDIR)/static/TTF/" $(STATICTTFS)
	install -Dm644 -t "$(DISTDIR)/static/WOFF/" $(STATICWOFFS)
	install -Dm644 -t "$(DISTDIR)/static/WOFF2/" $(STATICWOFF2S)
	install -Dm644 -t "$(DISTDIR)/variable/OTF/" $(VARIABLEOTFS)
	install -Dm644 -t "$(DISTDIR)/variable/TTF/" $(VARIABLETTFS)
	install -Dm644 -t "$(DISTDIR)/variable/WOFF/" $(VARIABLEWOFFS)
	install -Dm644 -t "$(DISTDIR)/variable/WOFF2/" $(VARIABLEWOFF2S)

install-local: install-local-otf

install-local-otf: otf variable-otf
	install -Dm755 -t "$${HOME}/.local/share/fonts/OTF/" $(STATICOTFS)
	install -Dm755 -t "$${HOME}/.local/share/fonts/variable/" $(VARIABLEOTFS)

install-local-ttf: ttf variable-ttf
	install -Dm755 -t "$${HOME}/.local/share/fonts/TTF/" $(STATICTTFS)
	install -Dm755 -t "$${HOME}/.local/share/fonts/variable/" $(VARIABLETTFS)

# Empty recipie to suppres makefile regeneration
$(MAKEFILE_LIST):;

# Special dependency to force rebuilds of up to date targets
.PHONY: force
force:;
