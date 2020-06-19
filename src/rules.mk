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

CANONICAL ?= $(shell git ls-files | grep -q '\.glyphs$'' && echo glyphs || echo ufo)

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
glyphs: $$(addsuffix .glyphs,$$(TARGETS))

.PHONY: fontforge
fontforge: $$(addsuffix .sfd,$$(TARGETS))

.PHONY: fonts
fonts: otf ttf variable woff woff2

OTFS = $$(addsuffix .otf,$$(TARGETS))
.PHONY: otf
otf: $(OTFS)

TTFS = $$(addsuffix .ttf,$$(TARGETS))
.PHONY: ttf
ttf: $(TTFS)

WOFFS = $$(addsuffix .woff,$$(TARGETS))
.PHONY: woff
woff: $(WOFFS)

WOFF2S = $$(addsuffix .woff2,$$(TARGETS))
.PHONY: woff2
woff2: $(WOFF2S)

VARIABLES = $$(addsuffix -VF.ttf,$$(FontBase))
.PHONY: variable
variable: $(VARIABLES)

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

%-VF.ttf: %.glyphs
	fontmake -g $< -o variable --output-path $@

instance_otf/$(FontBase)-%.otf: $(FontBase).glyphs
	fontmake --master-dir '{tmp}' -g $< -i "$(FontName) $*" -o otf

%.otf: instance_otf/%.otf
	cp $< $@

instance_ttf/$(FontBase)-%.ttf: $(FontBase).glyphs
	fontmake --master-dir '{tmp}' -g $< -i "$(FontName) $*" -o ttf
	gftools fix-dsig --autofix $@

$(FontBase)-%.ttf: instance_ttf/$(FontBase)-%.ttf
	ttfautohint $< $@

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
install-dist: all $(DISTDIR)
	install -Dm644 -t "$(DISTDIR)/OTF/" $(OTFS)
	install -Dm644 -t "$(DISTDIR)/TTF/" $(TTFS)

install-local: install-dist
	install -Dm755 -t "$${HOME}/.local/share/fonts/OTF/" $(DISTDIR)/OTF/*.otf
	install -Dm755 -t "$${HOME}/.local/share/fonts/TTF/" $(DISTDIR)/TTF/*.ttf

glyphWeights = $(shell python -c 'from glyphsLib import GSFont; list(map(lambda x: print(x.name), GSFont("$1").instances))')

define normalizeVersion =
	font-v write --ver=$(FontVersion) $(if $(isTagged),--rel,--dev --sha1) $@
endef

# Empty recipie to suppres makefile regeneration
$(MAKEFILE_LIST):;

# Special dependency to force rebuilds of up to date targets
.PHONY: force
force:;
