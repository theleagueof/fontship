glyphsFamilyNames ?= $(shell $(PYTHON) -c 'from glyphsLib import GSFont; print(GSFont("$1").familyName.title().replace(" ", ""))')
glyphsInstances ?= $(shell $(PYTHON) -c 'from glyphsLib import GSFont; list(map(lambda x: print(x.name.replace(" ", "")), GSFont("$1").instances))')
glyphsMasters ?= $(notdir $(basename $1))
ufoFamilyNames ?= $(shell $(PYTHON) -c 'import babelfont; print(babelfont.OpenFont("$1").info.openTypeNamePreferredFamilyName.title().replace(" ", ""))')
ufoInstances ?= $(shell $(PYTHON) -c 'import babelfont; print(babelfont.OpenFont("$1").info.styleName.replace(" ", ""))')
designspaceFamilyNames ?= $(shell $(PYTHON) -c 'from fontTools.designspaceLib import DesignSpaceDocument; d = DesignSpaceDocument(); d.read("$1");for i in d.instances: print(i.familyName.replace(" ", ""))')
designspaceInstances ?= $(shell $(PYTHON) -c 'from fontTools.designspaceLib import DesignSpaceDocument; d = DesignSpaceDocument(); d.read("$1");for i in d.instances: print(i.styleName.replace(" ", ""))')
designspaceMasters ?= $(notdir $(basename $1))
sfdFamilyNames = $(shell sed -n '/FamilyName/{s/.*: //;s/ //g;p}' "$1")
sfdInstances ?=

define normalizeVersion ?=
	$(FONTV) $(FONTVFLAGS) write --ver=$(FontVersion) $(if $(isTagged),--rel,--dev --sha1) $@
endef

define abort_if_not_clean ?=
	git diff-index --quiet --cached HEAD -- $@ || exit 1 # die if anything is staged
	git diff-files --quiet -- $@ || exit 1 # die if unstaged changes
endef

define addline ?=
	grep -Fxq "$1" $@ || echo "$1" >> $@
endef

define delline ?=
	grep -Fxv "$1" $@ | sponge $@
endef

# Useful for testing secondary expanstions in dependencies
ifTrue ?= $(and $1,$2)
