# If called using the fontship CLI the init rules will be sources before any
# project specific ones, then everything will be sourced in order. If people do
# a manual include to rules they may or may not know to source the
# initilazation rules first. this is to warn them.
ifeq ($(FONTSHIPDIR),)
$(error Please initialize Fontship by sourcing fontship.mk first, then include your project rules, then source this rules.mk file)
endif

SOURCES ?= $(shell git ls-files -- '$(SOURCEDIR)/*.glyphs' '$(SOURCEDIR)/*.sfd' '$(SOURCEDIR)/*.ufo/*' '$(SOURCEDIR)/*.designspace' | sed -e '/\.ufo/s,.ufo/.*,.ufo,' | uniq)
SOURCES_SFD ?= $(filter %.sfd,$(SOURCES))
SOURCES_UFO ?= $(filter %.ufo,$(SOURCES))
SOURCES_GLYPHS ?= $(filter %.glyphs,$(SOURCES))
SOURCES_DESIGNSPACE ?= $(filter %.designspace,$(SOURCES))
CANONICAL ?= $(or $(and $(SOURCES_GLYPHS),glyphs),$(and $(SOURCES_SFD),sfd),$(and $(SOURCES_UFO),ufo))

isVariable ?= $(and $(SOURCES_GLYPHS)$(SOURCES_DESIGNSPACE),true)

# Read font name from metadata file or guess from repository name
ifeq ($(CANONICAL),glyphs)
FamilyNames ?= $(sort $(foreach SOURCE,$(SOURCES_GLYPHS),$(call glyphsFamilyNames,$(SOURCE))))
FontInstances ?= $(sort $(foreach SOURCE,$(SOURCES_GLYPHS),$(call glyphsInstances,$(SOURCE))))
FamilyMasters ?= $(sort $(foreach SOURCE,$(SOURCES_GLYPHS),$(call designspaceMasters,$(SOURCE))))
endif

ifeq ($(CANONICAL),sfd)
FamilyNames ?= $(sort $(foreach SOURCE,$(SOURCES_SFD),$(call sfdFamilyNames,$(SOURCE))))
# FontInstances ?=
endif

ifeq ($(CANONICAL),ufo)
ifeq ($(isVariable),true)
FamilyNames ?= $(sort $(foreach SOURCE,$(SOURCES_DESIGNSPACE),$(call designspaceFamilyNames,$(SOURCE))))
FontInstances ?= $(sort $(foreach SOURCE,$(SOURCES_DESIGNSPACE),$(call designspaceInstances,$(SOURCE))))
FamilyMasters ?= $(sort $(foreach SOURCE,$(SOURCES_DESIGNSPACE),$(call designspaceMasters,$(SOURCE))))
else
FamilyNames ?= $(sort $(foreach SOURCE,$(SOURCES_UFO),$(call ufoFamilyNames,$(SOURCE))))
FontInstances ?= $(sort $(foreach SOURCE,$(SOURCES_UFO),$(call ufoInstances,$(SOURCE))))
endif
endif

FamilyName ?= $(shell $(CONTAINERIZED) || $(PYTHON) $(PYTHONFLAGS) -c 'print("$(PROJECT)".replace("-", " ").title())')

HINT ?= true

# Output format selectors
STATICOTF ?= true
STATICTTF ?= true
STATICWOFF ?= true
STATICWOFF2 ?= true
VARIABLEOTF ?=
VARIABLETTF ?= $(isVariable)
VARIABLEWOFF ?= $(isVariable)
VARIABLEWOFF2 ?= $(isVariable)

INSTANCES ?= $(foreach FamilyName,$(FamilyNames),$(foreach STYLE,$(FontInstances),$(FamilyName)-$(STYLE)))

GITVER = --tags --abbrev=6 --match='*[0-9].[0-9][0-9][0-9]'
# Determine font version automatically from repository git tags
FontVersion ?= $(shell git describe $(GITVER) 2> /dev/null | sed 's/^v//;s/-.*//g')
ifneq ($(FontVersion),)
FontVersionMeta ?= $(shell git describe --always --long $(GITVER) | sed 's/^v//;s/-[0-9]\+/;/;s/-g/[/')]
GitVersion ?= $(shell git describe $(GITVER) | sed 's/^v//;s/-/-r/')
isTagged := $(if $(subst $(FontVersion),,$(GitVersion)),,true)
else
FontVersion = 0.000
FontVersionMeta ?= $(FontVersion)\;[$(shell git rev-parse --short=6 HEAD)]
GitVersion ?= $(FontVersion)-r$(shell git rev-list --count HEAD)-g$(shell git rev-parse --short=6 HEAD)
isTagged :=
endif

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
SFDNORMALIZEFLAGS ?=
SFNT2WOFFFLAGS ?=
UFONORMALIZERFLAGS ?= -v
else
ifeq ($(VERBOSE),true)
MAKEFLAGS += --no-silent
FONTMAKEFLAGS ?= --verbose INFO
FONTVFLAGS ?=
GFTOOLSFLAGS ?=
PSAUTOHINTFLAGS ?= -vv
PYTHONFLAGS ?= -v
SFDNORMALIZEFLAGS ?=
SFNT2WOFFFLAGS ?=
TTFAUTOHINTFLAGS ?= -v
TTXFLAGS ?= -v
WOFF2COMPRESSFLAGS ?=
UFONORMALIZERFLAGS ?= -v
else
ifeq ($(QUIET),true)
FONTMAKEFLAGS ?= --verbose ERROR 2> /dev/null
FONTVFLAGS ?= 2> /dev/null
GFTOOLSFLAGS ?= > /dev/null
PSAUTOHINTFLAGS ?= 2> /dev/null
PYTHONFLAGS ?= 2> /dev/null
SFDNORMALIZEFLAGS ?= 2> /dev/null
SFNT2WOFFFLAGS ?= 2> /dev/null
TTFAUTOHINTFLAGS ?= 2> /dev/null
TTXFLAGS ?= 2> /dev/null
WOFF2COMPRESSFLAGS ?= 2> /dev/null
UFONORMALIZERFLAGS ?= -q 2> /dev/null
else
FONTMAKEFLAGS ?= --verbose WARNING
FONTVFLAGS ?=
GFTOOLSFLAGS ?=
PSAUTOHINTFLAGS ?= -v
PYTHONFLAGS ?=
SFDNORMALIZEFLAGS ?=
SFNT2WOFFFLAGS ?=
TTFAUTOHINTFLAGS ?=
TTXFLAGS ?=
WOFF2COMPRESSFLAGS ?=
UFONORMALIZERFLAGS ?=
endif
endif
endif

STATICOTFS = $(and $(STATICOTF),$(addsuffix .otf,$(INSTANCES)))
STATICTTFS = $(and $(STATICTTF),$(addsuffix .ttf,$(INSTANCES)))
STATICWOFFS = $(and $(STATICWOFF),$(addsuffix .woff,$(INSTANCES)))
STATICWOFF2S = $(and $(STATICWOFF2),$(addsuffix .woff2,$(INSTANCES)))
ifeq ($(isVariable),true)
VARIABLEOTFS = $(and $(VARIABLEOTF),$(addsuffix -VF.otf,$(FamilyMasters)))
VARIABLETTFS = $(and $(VARIABLETTF),$(addsuffix -VF.ttf,$(FamilyMasters)))
VARIABLEWOFFS = $(and $(VARIABLEWOFF),$(addsuffix -VF.woff,$(FamilyMasters)))
VARIABLEWOFF2S = $(and $(VARIABLEWOFF2),$(addsuffix -VF.woff2,$(FamilyMasters)))
endif

.PHONY: debug
debug:
	echo "FONTSHIPDIR = $(FONTSHIPDIR)"
	echo "GITNAME = $(GITNAME)"
	echo "PROJECT = $(PROJECT)"
	echo "PROJECTDIR = $(PROJECTDIR)"
	echo "PUBDIR = $(PUBDIR)"
	echo "SOURCEDIR = $(SOURCEDIR)"
	echo "----------------------------"
	echo "FamilyNames = $(FamilyNames)"
	echo "FontInstances = $(FontInstances)"
	echo "FontVersion = $(FontVersion)"
	echo "FontVersionMeta = $(FontVersionMeta)"
	echo "GitVersion = $(GitVersion)"
	echo "isTagged = $(isTagged)"
	echo "----------------------------"
	echo "CANONICAL = $(CANONICAL)"
	echo "isVariable = $(isVariable)"
	echo "SOURCES = $(SOURCES)"
	echo "SOURCES_SFD = $(SOURCES_SFD)"
	echo "SOURCES_GLYPHS = $(SOURCES_GLYPHS)"
	echo "SOURCES_UFO = $(SOURCES_UFO)"
	echo "SOURCES_DESIGNSPACE = $(SOURCES_DESIGNSPACE)"
	echo "INSTANCES = $(INSTANCES)"
	echo "STATICOTFS = $(STATICOTFS)"
	echo "STATICTTFS = $(STATICTTFS)"
	echo "STATICWOFFS = $(STATICWOFFS)"
	echo "STATICWOFF2S = $(STATICWOFF2S)"
	echo "VARIABLEOTFS = $(VARIABLEOTFS)"
	echo "VARIABLETTFS = $(VARIABLETTFS)"
	echo "VARIABLEWOFFS = $(VARIABLEWOFFS)"
	echo "VARIABLEWOFF2S = $(VARIABLEWOFF2S)"

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
normalize: NORMALIZE_MODE = true
normalize: $(SOURCES)

.gitignore: force
	$(abort_if_not_clean)
	$(call addline,.fontship)
	$(call addline,*.otf)
	$(call addline,*.ttf)
	$(call addline,*.woff)
	$(call addline,*.woff2)
	$(call addline,$(PROJECT)-*)
	$(call addline,!*/$(PROJECT)-*)
	$(call addline,.DS_Store)
	$(call addline,$(SOURCEDIR)/*$(lparen)Autosaved$(rparen).glyphs)
	$(call addline,$(SOURCEDIR)/*_backups)
ifneq ($(CANONICAL),glyphs)
	$(call addline,$(SOURCEDIR)/*.glyphs)
else
	$(call delline,$(SOURCEDIR)/*.glyphs)
endif
ifneq ($(CANONICAL),sfd)
	$(call addline,$(SOURCEDIR)/*.sfd)
else
	$(call delline,$(SOURCEDIR)/*.sfd)
endif
ifneq ($(CANONICAL),ufo)
	$(call addline,$(SOURCEDIR)/*.ufo)
else
	$(call delline,$(SOURCEDIR)/*.ufo)
endif

.PHONY: check
check: $(addsuffix -check,$(SOURCES))

$(BUILDDIR):
	mkdir -p $@

ifeq ($(PROJECT),Data)
$(warning We cannot read the Project’s name inside Docker. Please manually specify it by adding PROJECT='Name' as an agument to your command invocation)
endif

-include $(FONTSHIPDIR)/rules/$(CANONICAL).mk

$(foreach FamilyName,$(FamilyNames),$(eval $(call otf_instance_template,$(FamilyName))))
$(foreach FamilyName,$(FamilyNames),$(eval $(call ttf_instance_template,$(FamilyName))))

# Final steps common to all input formats

$(BUILDDIR)/%-hinted.ttf: $(BUILDDIR)/%-instance.ttf
	$(TTFAUTOHINT) $(TTFAUTOHINTFLAGS) -n $< $@

$(BUILDDIR)/%-hinted.ttf.fix: $(BUILDDIR)/%-hinted.ttf
	$(GFTOOLS) $(GFTOOLSFLAGS) fix-hinting $<

ifeq ($(HINT),true)
$(STATICTTFS): %.ttf: $(BUILDDIR)/%-hinted.ttf.fix $(BUILDDIR)/last-commit
	cp $< $@
	$(normalizeVersion)

$(VARIABLETTFS): %.ttf: $(BUILDDIR)/%-variable-hinted.ttf.fix $(BUILDDIR)/last-commit
	cp $< $@
	$(normalizeVersion)
else
$(STATICTTFS): %.ttf: $(BUILDDIR)/%-instance.ttf $(BUILDDIR)/last-commit
	cp $< $@
	$(normalizeVersion)

$(VARIABLETTFS): %.ttf: $(BUILDDIR)/%.ttf $(BUILDDIR)/last-commit
	cp $< $@
	$(normalizeVersion)
endif

$(VARIABLEOTFS): %.otf: $(BUILDDIR)/%-variable.otf $(BUILDDIR)/last-commit
	cp $< $@
	$(normalizeVersion)

$(BUILDDIR)/%-hinted.otf: $(BUILDDIR)/%-instance.otf
	$(PSAUTOHINT) $(PSAUTOHINTFLAGS) $< -o $@

$(BUILDDIR)/%-subr.otf: $(BUILDDIR)/%-$(if $(HINT),hinted,instance).otf
	$(PYTHON) -m cffsubr -o $@ $<

$(STATICOTFS): %.otf: $(BUILDDIR)/%-subr.otf $(BUILDDIR)/last-commit
	cp $< $@
	$(normalizeVersion)

# Webfont compressions

ifneq ($(STATICTTF),true)

%.woff: %.otf
	$(SFNT2WOFF) $(SFNT2WOFFFLAGS) $<

%.woff2: %.otf
	$(WOFF2COMPRESS) $(WOFF2COMPRESSFLAGS) $<

else

%.woff: %.ttf
	$(SFNT2WOFF) $(SFNT2WOFFFLAGS) $<

%.woff2: %.ttf
	$(WOFF2COMPRESS) $(WOFF2COMPRESSFLAGS) $<

endif

# Utility stuff

forceiftagchange = $(shell cmp -s $@ - <<< "$(GitVersion)" || echo force)
$(BUILDDIR)/last-commit: $$(forceiftagchange) | $(BUILDDIR)
	git update-index --refresh --ignore-submodules ||:
	git diff-index --quiet --cached HEAD -- $(SOURCES)
	echo $(GitVersion) > $@

DISTDIR = $(PROJECT)-$(GitVersion)

$(DISTDIR):
	mkdir -p $@

.PHONY: dist
dist: $(DISTDIR).zip $(DISTDIR).tar.xz

$(DISTDIR).tar.bz2 $(DISTDIR).tar.gz $(DISTDIR).tar.xz $(DISTDIR).zip $(DISTDIR).tar.zst: install-dist
	bsdtar -acf $@ $(DISTDIR)

_E = md txt markdown
dist_doc_DATA ?= $(wildcard $(foreach B,readme README contributors CONTRIBUTORS fontlog FONTLOG,$(foreach E,$(_E),$(B).$(E))))
dist_license_DATA ?= $(wildcard $(foreach B,ofl OFL ofl-faq OFL-FAQ license LICENSE copying COPYING copyingn-ofl COPYING-OFL authors AUTHORS,$(foreach E,$(_E),$(B).$(E))))

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
