glyphsFamilyNames ?= $(shell $(PYTHON) -c 'from glyphsLib import GSFont; print(GSFont("$1").familyName.title().replace(" ", ""))')
sfdFamilyNames ?=
ufoFamilyNames ?= $(shell $(PYTHON) -c 'import babelfont; print(babelfont.OpenFont("$1").info.familyName.title().replace(" ", ""))')
glyphsInstances ?= $(shell $(PYTHON) -c 'from glyphsLib import GSFont; list(map(lambda x: print(x.name), GSFont("$1").instances))')
ufoInstances ?= $(shell $(PYTHON) -c 'import babelfont; print(babelfont.OpenFont("$1").info.styleName)')
sfdInstances ?=

file2family ?= $(shell $(PYTHON) -c 'import re; print(re.sub(r"(?<!^)(?=[A-Z])", " ", "$1"))')

define normalizeVersion ?=
	$(FONTV) $(FONTVFLAGS) write --ver=$(FontVersion) $(if $(isTagged),--rel,--dev --sha1) $@
endef

parseCheckName ?= $(patsubst %.glyphs,%-check.glyphs,$(patsubst %.ufo,%-check.ufo,$(patsubst %.sfd,%-check.sfd,$(patsubst $(SOURCEDIR)/%,$(BUILDDIR)/%,$1))))
# Same thing in sed is way simpler, but 2× orders of magnitude slower
# parseCheckName ?= $(shell <<< $1 sed -e 's/\(\.[[:alpha:]]\+\)\b/-check\1/g')
