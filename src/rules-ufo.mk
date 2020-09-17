ufoNormalize ?= $(UFONORMALIZER) $(UFONORMALIZERFLAGS) "$1" -o "$2"
expandUFOParts = $(shell find "$1" -type f 2> /dev/null)
ufoParts = $(call expandUFOParts,$(patsubst %-normalized.ufo,%.ufo,$(patsubst $(BUILDDIR)/%,$(SOURCEDIR)/%,$@)))
instanceToDS = $(_DSF_$(subst -,,$*))

define makeVars =
from fontTools.designspaceLib import DesignSpaceDocument
designspace = DesignSpaceDocument()
designspace.read("$(SOURCE)")
for instance in designspace.instances: print("_DSI_{1}{0} = {1} {2}\n_DSF_{1}{0} = $(SOURCE)".format(instance.styleName.replace(" ", ""), instance.familyName, instance.styleName))
endef

ifneq ($(SOURCES_DESIGNSPACE),)
_TMP = $(shell local tmp=$$(mktemp vars-XXXXXX.mk); echo $${tmp}; {$(foreach SOURCE,$(SOURCES_DESIGNSPACE),$(PYTHON) -c '$(makeVars)';)} >> $${tmp})
$(eval $(file < $(_TMP)))
$(shell rm -f $(_TMP))
endif

$(BUILDDIR)/%-VF.ttf: $(SOURCEDIR)/%.designspace | $(BUILDDIR)
	$(FONTMAKE) $(FONTMAKEFLAGS) -m "$<" -o variable --output-path $@
	$(GFTOOLS) $(GFTOOLSFLAGS) fix-vf-meta $@
	$(GFTOOLS) $(GFTOOLSFLAGS) fix-unwanted-tables --tables MVAR $@ ||:
	$(GFTOOLS) $(GFTOOLSFLAGS) fix-dsig -f $@

$(BUILDDIR)/%-hinted.ttf: $(if $(wildcard $(SOURCEDIR)/*-vtt.ttx),$(BUILDDIR)/%-vtthinted.ttf,$(BUILDDIR)/%.ttf)
	$(and $(filter %-vtthinted.ttf,$<),$(PYTHON) -m vttLib compile --ship $< $@)
	$(and $(filter-out %-vtthinted.ttf,$<),$(TTFAUTOHINT) $(TTFAUTOHINTFLAGS) -n $< $@)

$(BUILDDIR)/%-VF-vtthinted.ttf: $(BUILDDIR)/%-VF.ttf $(SOURCEDIR)/%-vtt.ttx
	cp $< $@
	python -m vttLib mergefile $(filter %.ttx,$^) $@

$(BUILDDIR)/%-hinted.ttf.fix: $(BUILDDIR)/%-hinted.ttf
	$(GFTOOLS) $(GFTOOLSFLAGS) fix-hinting $<
	$(GFTOOLS) $(GFTOOLSFLAGS) fix-gasp $@

$(VARIABLETTFS): %.ttf: $(BUILDDIR)/%-hinted.ttf.fix $(BUILDDIR)/last-commit
	cp $< $@
	$(normalizeVersion)

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

# TODO: When upstream fontmake bug gets fixed do something sane here...
# https://github.com/googlefonts/fontmake/issues/693
# $(BUILDDIR)/%-normalized.ufo: FONTMAKEFLAGS += --instance-dir '{tmp}'
# $(BUILDDIR)/%-normalized.ufo: FONTMAKEFLAGS += --output-dir '$(BUILDDIR)' --output-path $@
# --output-path $@
$(BUILDDIR)/%-normalized.ufo: $$(instanceToDS) | $(BUILDDIR)
	$(FONTMAKE) $(FONTMAKEFLAGS) -m "$<" -i "$(_DSI_$(subst -,,$*))" -o ufo
	$(call ufoNormalize,$(SOURCEDIR)/instance_ufos/$*.ufo,$@)

# UFO -> OTF

define otf_instance_template ?=

$$(BUILDDIR)/$1-%-instance.otf: $(BUILDDIR)/$1-%-normalized.ufo | $$(BUILDDIR)
	$$(FONTMAKE) $$(FONTMAKEFLAGS) -u $$< -o otf --output-path $$@
	$$(GFTOOLS) $$(GFTOOLSFLAGS) fix-dsig -f $$@

endef

# UFO -> TTF

define ttf_instance_template ?=

$$(BUILDDIR)/$1-%-instance.ttf: $(BUILDDIR)/$1-%-normalized.ufo | $$(BUILDDIR)
	$$(FONTMAKE) $$(FONTMAKEFLAGS) -u $$< -o ttf --output-path $$@
	$$(GFTOOLS) $$(GFTOOLSFLAGS) fix-dsig -f $$@

endef
