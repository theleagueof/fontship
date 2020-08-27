glyphsFamilyNames ?= $(shell $(PYTHON) -c 'from glyphsLib import GSFont; print(GSFont("$1").familyName.title().replace(" ", ""))')
glyphsInstances ?= $(shell $(PYTHON) -c 'from glyphsLib import GSFont; list(map(lambda x: print(x.name), GSFont("$1").instances))')
glyphsMasters ?= $(notdir $(basename $1))
ufoFamilyNames ?= $(shell $(PYTHON) -c 'import babelfont; print(babelfont.OpenFont("$1").info.familyName.title().replace(" ", ""))')
ufoInstances ?= $(shell $(PYTHON) -c 'import babelfont; print(babelfont.OpenFont("$1").info.styleName.replace(" ", ""))')
designspaceFamilyNames ?= $(shell $(PYTHON) -c 'from fontTools.designspaceLib import DesignSpaceDocument; d = DesignSpaceDocument(); d.read("$1");for i in d.instances: print(i.familyName.replace(" ", ""))')
designspaceInstances ?= $(shell $(PYTHON) -c 'from fontTools.designspaceLib import DesignSpaceDocument; d = DesignSpaceDocument(); d.read("$1");for i in d.instances: print(i.styleName.replace(" ", ""))')
designspaceMasters ?= $(notdir $(basename $1))
sfdFamilyNames = $(shell sed -n '/FamilyName/{s/.*: //;s/ //g;p}' "$1")
sfdInstances ?=

file2family ?= $(shell $(PYTHON) -c 'import re; print(re.sub(r"(?<!^)(?=[A-Z])", " ", "$1"))')

define normalizeVersion ?=
	$(FONTV) $(FONTVFLAGS) write --ver=$(FontVersion) $(if $(isTagged),--rel,--dev --sha1) $@
endef

# Useful for testing secondary expanstions in dependencies
ifTrue ?= $(and $1,$2)
