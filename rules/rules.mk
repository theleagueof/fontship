# If called using the fontship CLI the init rules will be sourced before any
# project specific ones, then everything will be sourced in order. If people do
# a manual include to rules they may or may not know to source the
# initialization rules first. This is to warn them.
ifeq ($(FONTSHIPDIR),)
$(error Please initialize Fontship by sourcing fontship.mk first, then include your project rules, then source this rules.mk file)
endif

# Empty recipes for anything we _don't_ want to bother rebuilding:
$(MAKEFILE_LIST):;

SOURCES_SFD ?= $(filter %.sfd,$(SOURCES))
SOURCES_UFO ?= $(filter %.ufo,$(SOURCES))
SOURCES_GLYPHS ?= $(filter %.glyphs,$(SOURCES))
SOURCES_DESIGNSPACE ?= $(filter %.designspace,$(SOURCES))
CANONICAL ?= $(or $(and $(SOURCES_GLYPHS),glyphs),$(and $(SOURCES_SFD),sfd),$(and $(SOURCES_UFO),ufo))

isVariable ?= $(and $(SOURCES_GLYPHS)$(SOURCES_DESIGNSPACE),true)

# Read font name from metadata file or guess from repository name
ifeq ($(CANONICAL),glyphs)
_FamilyNames := $(sort $(foreach SOURCE,$(SOURCES_GLYPHS),$(call glyphsFamilyNames,$(SOURCE))))
_FontInstances := $(sort $(foreach SOURCE,$(SOURCES_GLYPHS),$(call glyphsInstances,$(SOURCE))))
_FamilyMasters := $(sort $(foreach SOURCE,$(SOURCES_GLYPHS),$(call designspaceMasters,$(SOURCE))))
endif

ifeq ($(CANONICAL),sfd)
_FamilyNames := $(sort $(foreach SOURCE,$(SOURCES_SFD),$(call sfdFamilyNames,$(SOURCE))))
_FontInstances := $(sort $(foreach SOURCE,$(SOURCES_SFD),$(call sfdInstances,$(SOURCE))))
endif

ifeq ($(CANONICAL),ufo)
ifeq ($(isVariable),true)
_FamilyNames := $(sort $(foreach SOURCE,$(SOURCES_DESIGNSPACE),$(call designspaceFamilyNames,$(SOURCE))))
_FontInstances := $(sort $(foreach SOURCE,$(SOURCES_DESIGNSPACE),$(call designspaceInstances,$(SOURCE))))
_FamilyMasters := $(sort $(foreach SOURCE,$(SOURCES_DESIGNSPACE),$(call designspaceMasters,$(SOURCE))))
else
_FamilyNames := $(sort $(foreach SOURCE,$(SOURCES_UFO),$(call ufoFamilyNames,$(SOURCE))))
_FontInstances := $(sort $(foreach SOURCE,$(SOURCES_UFO),$(call ufoInstances,$(SOURCE))))
endif
endif

FamilyNames ?= $(_FamilyNames)
FontInstances ?= $(_FontInstances)
FamilyMasters ?= $(_FamilyMasters)

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

isTagged := $(and $(findstring -r0-,$(GitVersion)),true)

DEBUG ?=
VERBOSE ?=
QUIET ?=

ifeq ($(DEBUG),true)
.SHELLFLAGS += -x
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
VARIABLEOTFS = $(and $(VARIABLEOTF),$(addsuffix -VF.otf,$(FamilyMasters)))
VARIABLETTFS = $(and $(VARIABLETTF),$(addsuffix -VF.ttf,$(FamilyMasters)))
VARIABLEWOFFS = $(and $(VARIABLEWOFF),$(addsuffix -VF.woff,$(FamilyMasters)))
VARIABLEWOFF2S = $(and $(VARIABLEWOFF2),$(addsuffix -VF.woff2,$(FamilyMasters)))

.PHONY: debug
debug:
	echo "FONTSHIPDIR = $(FONTSHIPDIR)"
	echo "GITNAME = $(GITNAME)"
	echo "PROJECT = $(PROJECT)"
	echo "PROJECTDIR = $(PROJECTDIR)"
	echo "BUILDDIR = $(BUILDDIR)"
	echo "SOURCEDIR = $(SOURCEDIR)"
	echo "CONTAINERIZED = $(CONTAINERIZED)"
	echo "----------------------------"
	echo "FamilyNames = $(FamilyNames)"
	echo "FontInstances = $(FontInstances)"
	echo "FontVersion = $(FontVersion)"
	echo "GitVersion = $(GitVersion)"
	echo "isTagged = $(isTagged)"
	echo "isVariable = $(isVariable)"
	echo "CANONICAL = $(CANONICAL)"
	echo "DISTDIR = $(DISTDIR)"
	echo "----------------------------"
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

# Special dependency to force rebuilds of up to date targets
.PHONY: force
force:;

.PHONY: fail

.PHONY: _gha
_gha:
	exec >> $${GITHUB_OUTPUT:-/dev/stdout}
	echo "family-names=$(FamilyNames)"
	echo "font-version=$(FontVersion)"
	echo "DISTDIR=$(DISTDIR)"
	echo "PROJECT=$(PROJECT)"

.PHONY: all
all: fonts $(call ifTrue,$(DEBUG),debug)

.PHONY: clean
clean:
	$(GIT) clean -dxf

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

_VTTSOURCES := $(wildcard $(SOURCEDIR)/*-vtt.ttx)
ifneq ($(_VTTSOURCES),)

$(BUILDDIR)/%-VF-variable-vtthinted.otf: $(BUILDDIR)/%-VF-variable.otf $(SOURCEDIR)/%-vtt.ttx
	cp $< $@
	python -m vttLib mergefile $(filter %.ttx,$^) $@

$(BUILDDIR)/%-VF-variable-vtthinted.ttf: $(BUILDDIR)/%-VF-variable.ttf $(SOURCEDIR)/%-vtt.ttx
	cp $< $@
	python -m vttLib mergefile $(filter %.ttx,$^) $@

$(BUILDDIR)/%-hinted.otf: $(BUILDDIR)/%-vtthinted.otf
	$(PYTHON) -m vttLib compile --ship $< $@

$(BUILDDIR)/%-hinted.ttf: $(BUILDDIR)/%-vtthinted.ttf
	$(PYTHON) -m vttLib compile --ship $< $@

endif

$(BUILDDIR)/%-hinted.otf: $(BUILDDIR)/%.otf
	$(PSAUTOHINT) $(PSAUTOHINTFLAGS) -o $@ $<

$(BUILDDIR)/%-hinted.ttf: $(BUILDDIR)/%.ttf
	$(TTFAUTOHINT) $(TTFAUTOHINTFLAGS) -n $< $@

$(STATICTTFS): %.ttf: $(BUILDDIR)/%-instance$(and $(HINT),-hinted).ttf $(BUILDDIR)/last-commit
	export PROTOCOL_BUFFERS_PYTHON_IMPLEMENTATION=python
	$(GFTOOLS) $(GFTOOLSFLAGS) fix-font -o $@ $<
	$(normalizeVersion)

$(BUILDDIR)/%-subr.otf: $(BUILDDIR)/%-instance$(and $(HINT),-hinted).otf
	$(PYTHON) -m cffsubr -o $@ $<

$(STATICOTFS): %.otf: $(BUILDDIR)/%-subr.otf $(BUILDDIR)/last-commit
	export PROTOCOL_BUFFERS_PYTHON_IMPLEMENTATION=python
	$(GFTOOLS) $(GFTOOLSFLAGS) fix-font -o $@ $<
	$(normalizeVersion)

$(VARIABLEOTFS): %.otf: $(BUILDDIR)/%-variable$(and $(_VTTSOURCES),-hinted).otf $(BUILDDIR)/last-commit
	export PROTOCOL_BUFFERS_PYTHON_IMPLEMENTATION=python
	$(GFTOOLS) $(GFTOOLSFLAGS) fix-font -o $@ $<
	$(normalizeVersion)

$(VARIABLETTFS): %.ttf: $(BUILDDIR)/%-variable$(and $(_VTTSOURCES),-hinted).ttf $(BUILDDIR)/last-commit
	export PROTOCOL_BUFFERS_PYTHON_IMPLEMENTATION=python
	$(GFTOOLS) $(GFTOOLSFLAGS) fix-font -o $@ $<
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

forceiftagchange = $(shell $(_ENV) $(CMP) -s $@ - <<< "$(GitVersion)" || echo force)
$(BUILDDIR)/last-commit: $$(forceiftagchange) | $(BUILDDIR)
	$(GIT) update-index --refresh --ignore-submodules ||:
	$(GIT) diff-index --quiet --cached HEAD -- $(SOURCES)
	echo $(GitVersion) > $@

DISTDIR ?= $(PROJECT)-$(if $(isTagged),$(FontVersion),$(GitVersion))

$(DISTDIR):
	mkdir -p $@

.PHONY: dist
dist: $(DISTDIR).zip $(DISTDIR).tar.zst

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

POSTFONTSHIPEVAL ?=
ifneq (,$(POSTFONTSHIPEVAL))
$(eval $(POSTFONTSHIPEVAL))
endif

POSTFONTSHIPINCLUDE ?=
ifneq (,$(POSTFONTSHIPINCLUDE))
-include $(POSTFONTSHIPINCLUDE)
endif
