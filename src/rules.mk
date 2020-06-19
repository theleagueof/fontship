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

# Initial environment setup
FONTSHIPDIR != cd "$(shell dirname $(lastword $(MAKEFILE_LIST)))/" && pwd
GITNAME := $(notdir $(shell git worktree list | head -n1 | awk '{print $$1}'))
PROJECT ?= $(GITNAME)
_PROJECTDIR != cd "$(shell dirname $(firstword $(MAKEFILE_LIST)))/" && pwd
PROJECTDIR ?= $(_PROJECTDIR)
PUBDIR ?= $(PROJECTDIR)/pub
# Some Makefile shinanigans to avoid aggressive trimming
space := $() $()

# Allow overriding executables used
FONTV ?= font-v
PYTHON ?= python3

# Read font name from metadata file or guess from repository name
FontName ?= $(shell python -c 'print("$(PROJECT)".replace("-", " ").title())')

# Determine font version automatically from repository git tags
FontVersion ?= $(shell git describe --tags --abbrev=6 | sed 's/-.*//g')
FontVersionMeta ?= $(shell git describe --tags --abbrev=6 --long | sed 's/-[0-9]\+/\\;/;s/-g/[/')]
GitVersion ?= $(shell git describe --tags --abbrev=6 | sed 's/-/-r/')
isTagged := $(if $(subst $(FontVersion),,$(GitVersion)),,true)

# Look for what fonts & styles are in this repository that will need building
FontBase = $(subst $(space),,$(FontName))
FontStyles = $(subst $(FontBase)-,,$(basename $(wildcard $(FontBase)-*.ufo)))
FontStyles += $(foreach GLYPHS,$(wildcard $(FontBase).glyphs),$(call glyphWeights,$(GLYPHS)))

TARGETS = $(foreach BASE,$(FontBase),$(foreach STYLE,$(FontStyles),$(BASE)-$(STYLE)))

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
	echo FontName = $(FontName)
	echo FontBase: $(FontBase)
	echo FontStyles: $(FontStyles)
	echo FontVersion: $(FontVersion)
	echo FontVersionMeta: $(FontVersionMeta)
	echo GitVersion: $(GitVersion)
	echo isTagged: $(isTagged)
	echo ----------------------------
	echo TARGETS: $(TARGETS)

.PHONY: all
all: debug fonts

.PHONY: clean
clean:
	git clean -dxf

.PHONY: glyphs
glyphs: $(addsuffix .glyphs,$(TARGETS))

.PHONY: fontforge
fontforge: $(addsuffix .sfd,$(TARGETS))

.PHONY: fonts
fonts: otf ttf

.PHONY: otf
otf: $(addsuffix .otf,$(TARGETS))

.PHONY: ttf
ttf: $(addsuffix .ttf,$(TARGETS))

%.glyphs: %.ufo
	fontmake -u $< -o glyphs

%.designspace: %.glyphs
	echo MM $@

%.sfd: %.ufo
	echo SDF: $@

# %.ufo: %.glyphs
#     fontmake -g $< -o ufo

%.ufo: .last-commit
	cat <<- EOF | $(PYTHON)
		from defcon import Font, Info
		ufo = Font('$@')
		major, minor = "$(FontVersion)".split(".")
		ufo.info.versionMajor, ufo.info.versionMinor = int(major), int(minor) + 7
		ufo.save('$@')
	EOF

%.otf: %.ufo
	cat <<- EOF | $(PYTHON)
		from ufo2ft import compileOTF
		from defcon import Font
		ufo = Font('$<')
		otf = compileOTF(ufo)
		otf.save('$@')
	EOF
	$(normalizeVersion)

%.ttf: %.ufo
	cat <<- EOF | $(PYTHON)
		from ufo2ft import compileTTF
		from defcon import Font
		ufo = Font('$<')
		ttf = compileTTF(ufo)
		ttf.save('$@')
	EOF
	$(normalizeVersion)

$(FontBase)-%.ttf: $(FontBase).glyphs
	fontmake -g $< -i "$(FontName) $*" -o ttf

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
install-dist: all $(DISTDIR)
	install -Dm644 -t "$(DISTDIR)/OTF/" *.otf
	install -Dm644 -t "$(DISTDIR)/TTF/" *.ttf

install-local: install-dist
	install -Dm755 -t "$${HOME}/.local/share/fonts/OTF/" $(DISTDIR)/OTF/*.otf
	install -Dm755 -t "$${HOME}/.local/share/fonts/TTF/" $(DISTDIR)/TTF/*.ttf

glyphWeights = $(shell awk -F'[=; ]*' '/weightClass/ {print $$2}' $1)

define normalizeVersion =
	font-v write --ver=$(FontVersion) $(if $(isTagged),--rel,--dev --sha1) $@
endef

# Empty recipie to suppres makefile regeneration
$(MAKEFILE_LIST):;

# Special dependency to force rebuilds of up to date targets
.PHONY: force
force:;
