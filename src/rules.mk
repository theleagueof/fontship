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
FONTV ?= font-v
PYTHON ?= python3

include $(FONTSHIPDIR)/functions.mk

# Read font name from metadata file or guess from repository name
FamilyName ?= $(shell $(CONTAINERIZED) || python -c 'print("$(PROJECT)".replace("-", " ").title())')

ifeq ($(FamilyName),)
$(error We cannot properly detect the font’s Family Name yet from inside Docker. Please manually specify it by adding FamilyName='Family Name' as an agument to your command invocation)
endif

# Determine font version automatically from repository git tags
FontVersion ?= $(shell git describe --tags --abbrev=6 | sed 's/-.*//g')
FontVersionMeta ?= $(shell git describe --tags --abbrev=6 --long | sed 's/-[0-9]\+/\\;/;s/-g/[/')]
GitVersion ?= $(shell git describe --tags --abbrev=6 | sed 's/-/-r/')
isTagged := $(if $(subst $(FontVersion),,$(GitVersion)),,true)

# Look for what fonts & styles are in this repository that will need building
FontBase = $(subst $(space),,$(FamilyName))
FontStyles = $(subst $(FontBase)-,,$(basename $(wildcard $(FontBase)-*.ufo)))
FontStyles += $(foreach GLYPHS,$(wildcard $(FontBase).glyphs),$(call glyphWeights,$(GLYPHS)))

TARGETS = $(foreach BASE,$(FontBase),$(foreach STYLE,$(FontStyles),$(BASE)-$(STYLE)))

OTFS = $(addsuffix .otf,$(TARGETS))
TTFS = $(addsuffix .ttf,$(TARGETS))
WOFFS = $(addsuffix .woff,$(TARGETS)) $(addsuffix -VF.woff,$(FontBase))
WOFF2S = $(addsuffix .woff2,$(TARGETS)) $(addsuffix -VF.woff2,$(FontBase))
VARIABLES = $(addsuffix -VF.ttf,$(FontBase))

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
	echo TARGETS: $(TARGETS)
	echo OTFS: $(OTFS)
	echo TTFS: $(TTFS)
	echo WOFFS: $(WOFFS)
	echo WOFF2S: $(WOFF2S)
	echo VARIABLES: $(VARIABLES)

.PHONY: all
all: debug fonts

.PHONY: clean
clean:
	git clean -dxf

.PHONY: glyphs
glyphs: $$(addsuffix .glyphs,$$(TARGETS))

.PHONY: fontforge
fontforge: $$(addsuffix .sfd,$$(TARGETS))

.PHONY: fonts
fonts: otf ttf variable woff woff2

.PHONY: otf
otf: $$(OTFS)

.PHONY: ttf
ttf: $$(TTFS)

.PHONY: woff
woff: $$(WOFFS)

.PHONY: woff2
woff2: $$(WOFF2S)

.PHONY: variable
variable: $$(VARIABLES)

ifeq (glyphs,$(CANONICAL))

%.glyphs: %.ufo
	fontmake -u $< -o glyphs

# %.ufo: %.glyphs
#     fontmake -g $< -o ufo

%.designspace: %.glyphs
	echo MM $@

endif

ifeq (ufo,$(CANONICAL))

%.sfd: %.ufo
	echo SDF: $@

%.ufo: .last-commit
	cat <<- EOF | $(PYTHON)
		from defcon import Font, Info
		ufo = Font('$@')
		major, minor = "$(FontVersion)".split(".")
		ufo.info.versionMajor, ufo.info.versionMinor = int(major), int(minor) + 7
		ufo.save('$@')
	EOF

endif

%.otf: %.ufo .last-commit
	cat <<- EOF | $(PYTHON)
		from ufo2ft import compileOTF
		from defcon import Font
		ufo = Font('$<')
		otf = compileOTF(ufo)
		otf.save('$@')
	EOF
	$(normalizeVersion)

%.ttf: %.ufo .last-commit
	cat <<- EOF | $(PYTHON)
		from ufo2ft import compileTTF
		from defcon import Font
		ufo = Font('$<')
		ttf = compileTTF(ufo)
		ttf.save('$@')
	EOF
	$(normalizeVersion)

variable_ttf/%-VF.ttf: %.glyphs
	fontmake -g $< -o variable
	gftools fix-dsig --autofix $@

%.ttf: variable_ttf/%.ttf .last-commit
	gftools fix-nonhinting $< $@
	ttx -f -x "MVAR" $@
	rm $@
	ttx $(@:.ttf=.ttx)
	$(normalizeVersion)

instance_otf/$(FontBase)-%.otf: $(FontBase).glyphs
	fontmake --master-dir '{tmp}' -g $< -i "$(FamilyName) $*" -o otf

%.otf: instance_otf/%.otf .last-commit
	cp $< $@
	$(normalizeVersion)

instance_ttf/$(FontBase)-%.ttf: $(FontBase).glyphs
	fontmake --master-dir '{tmp}' -g $< -i "$(FamilyName) $*" -o ttf
	gftools fix-dsig --autofix $@

%.ttf: instance_ttf/%.ttf .last-commit
	ttfautohint $< $@
	$(normalizeVersion)

%.woff: %.ttf
	sfnt2woff-zopfli $<

%.woff2: %.ttf
	woff2_compress $<

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

.PHONY: install-dist
install-dist: fonts $(DISTDIR)
	install -Dm644 -t "$(DISTDIR)/OTF/" $(OTFS)
	install -Dm644 -t "$(DISTDIR)/TTF/" $(TTFS)
	install -Dm644 -t "$(DISTDIR)/WOFF/" $(WOFFS)
	install -Dm644 -t "$(DISTDIR)/WOFF2/" $(WOFF2S)
	install -Dm644 -t "$(DISTDIR)/variable/" $(VARIABLES)

install-local: install-dist
	install -Dm755 -t "$${HOME}/.local/share/fonts/OTF/" $(DISTDIR)/OTF/*.otf
	install -Dm755 -t "$${HOME}/.local/share/fonts/TTF/" $(DISTDIR)/TTF/*.ttf
	install -Dm755 -t "$${HOME}/.local/share/fonts/variable/" $(DISTDIR)/variable/*.ttf

# Empty recipie to suppres makefile regeneration
$(MAKEFILE_LIST):;

# Special dependency to force rebuilds of up to date targets
.PHONY: force
force:;
