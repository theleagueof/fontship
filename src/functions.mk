glyphWeights = $(shell $(PYTHON) -c 'from glyphsLib import GSFont; list(map(lambda x: print(x.name), GSFont("$1").instances))')
familyName = $(shell $(PYTHON) -c 'from glyphsLib import GSFont; print(GSFont("$1").familyName)')

define normalizeVersion =
	$(FONT-V) write --ver=$(FontVersion) $(if $(isTagged),--rel,--dev --sha1) $@
endef
