ufoNormalize ?= $(UFONORMALIZER) $(UFONORMALIZERFLAGS) "$1" -o "$2"
expandUFOParts = $(shell find "$1" -type f 2> /dev/null)
ufoParts = $(call expandUFOParts,$(patsubst %-normalized.ufo,%.ufo,$(patsubst $(BUILDDIR)/%,$(SOURCEDIR)/%,$@)))

$(SOURCEDIR)/%.ufo: UFONORMALIZERFLAGS += -m
$(SOURCEDIR)/%.ufo: $$(call ifTrue,$$(NORMALIZE_MODE),force) | $(BUILDDIR)
	local _normalized=$(BUILDDIR)/$(*F)-normalized.ufo
	$(call ufoNormalize,$@,$${_normalized})
	cp -aT --remove-destination $${_normalized} $@
	touch $@

$(BUILDDIR)/%-normalized.ufo: UFONORMALIZERFLAGS += -a
$(BUILDDIR)/%-normalized.ufo: $(SOURCEDIR)/%.ufo $$(ufoParts) | $(BUILDDIR)
	$(call ufoNormalize,$<,$@)
	touch $@

# UFO -> OTF

define otf_instance_template ?=
$$(BUILDDIR)/$1-%-instance.otf: $(BUILDDIR)/$1-%-normalized.ufo | $$(BUILDDIR)
	$$(FONTMAKE) $$(FONTMAKEFLAGS) -u $$< -o otf --output-path $$@
endef

# UFO -> TTF

define ttf_instance_template ?=
$$(BUILDDIR)/$1-%-instance.ttf: $(BUILDDIR)/$1-%-normalized.ufo | $$(BUILDDIR)
	$$(FONTMAKE) $$(FONTMAKEFLAGS) -u $$< -o ttf --output-path $$@
	$$(GFTOOLS) $$(GFTOOLSFLAGS) fix-dsig --autofix $$@
endef
