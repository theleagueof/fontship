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

# TODO: Use an earlier generated map to find the relevant designspace instead of this hack
fromDS = $(shell <<< "$(*F)X" sed -e 's/Italic/X/;s/-[^X]*//;s/XX/-Italic/;s/X//').designspace

# TODO: When upstream fontmake bug gets fixed do something sane here...
# https://github.com/googlefonts/fontmake/issues/693
# $(BUILDDIR)/%-normalized.ufo: FONTMAKEFLAGS += --instance-dir '{tmp}'
# $(BUILDDIR)/%-normalized.ufo: FONTMAKEFLAGS += --output-dir '$(BUILDDIR)' --output-path $@
# --output-path $@
$(BUILDDIR)/%-normalized.ufo: $(SOURCEDIR)/$$(fromDS) | $(BUILDDIR)
	$(FONTMAKE) $(FONTMAKEFLAGS) -m $< -i "$(call file2family,$(subst -,,$*))" -o ufo
	$(call ufoNormalize,$(SOURCEDIR)/instance_ufos/$*.ufo,$@)

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
