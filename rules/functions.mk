# Utility variables for later, http://blog.jgc.org/2007/06/escaping-comma-and-space-in-gnu-make.html
, := ,
empty :=
space := $(empty) $(empty)
$(space) := $(empty) $(empty)
lparen := (
rparen := )

glyphsFamilyNames ?= $(shell $(_ENV) $(PYTHON) -c 'from glyphsLib import GSFont; print(GSFont("$1").familyName.title().replace(" ", ""))')
glyphsInstances ?= $(shell $(_ENV) $(PYTHON) -c 'from glyphsLib import GSFont; list(map(lambda x: print(x.name.replace(" ", "")), GSFont("$1").instances))')
glyphsMasters ?= $(notdir $(basename $1))
ufoFamilyNames ?= $(shell $(_ENV) $(PYTHON) -c 'import babelfont; print(babelfont.Babelfont.open("$1").info.familyName.title().replace(" ", ""))')
ufoInstances ?= $(shell $(_ENV) $(PYTHON) -c 'import babelfont; print(babelfont.Babelfont.open("$1").info.styleName.replace(" ", ""))')
designspaceFamilyNames ?= $(shell $(_ENV) $(PYTHON) -c 'from fontTools.designspaceLib import DesignSpaceDocument; d = DesignSpaceDocument(); d.read("$1");for i in d.instances: print(i.familyName.replace(" ", ""))')
designspaceInstances ?= $(shell $(_ENV) $(PYTHON) -c 'from fontTools.designspaceLib import DesignSpaceDocument; d = DesignSpaceDocument(); d.read("$1");for i in d.instances: print(i.styleName.replace(" ", ""))')
designspaceMasters ?= $(notdir $(basename $1))
sfdFamilyNames = $(shell $(_ENV) $(SED) -n '/^FamilyName/{s/.*: //;s/ //g;p}' "$1")
sfdInstances ?= $(shell $(_ENV) $(SED) -n '/^FontName:/{s/^.*-//g;p}' "$1")

define normalizeVersion ?=
	$(FONTV) $(FONTVFLAGS) write --ver=$(FontVersion) $(if $(isTagged),--rel,--dev --sha1) $@
endef

define abort_if_not_clean ?=
	$(GIT) diff-index --quiet --cached HEAD -- $@ || exit 1 # die if anything is staged
	$(GIT) diff-files --quiet -- $@ || exit 1 # die if unstaged changes
endef

define addline ?=
	$(GREP) -Fxq "$1" $@ || echo "$1" >> $@
endef

define delline ?=
	$(GREP) -Fxv "$1" $@ | sponge $@
endef

# Useful for testing secondary expanstions in dependencies
ifTrue ?= $(and $1,$2)
