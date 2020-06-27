glyphInstances = $(shell $(PYTHON) -c 'from glyphsLib import GSFont; list(map(lambda x: print(x.name), GSFont("$1").instances))')
glyphsFamilyName = $(shell $(PYTHON) -c 'from glyphsLib import GSFont; print(GSFont("$1").familyName)')
ufoInstances = $(shell $(PYTHON) -c 'import babelfont; print(babelfont.OpenFont("$1").info.styleName)')
ufoFamilyName = $(shell $(PYTHON) -c 'import babelfont; print(babelfont.OpenFont("$1").info.familyName)')

define normalizeVersion =
	$(FONTV) $(FONTVFLAGS) write --ver=$(FontVersion) $(if $(isTagged),--rel,--dev --sha1) $@
endef
