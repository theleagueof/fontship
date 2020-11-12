FONTMAKEFLAGS += --master-dir '{tmp}' --instance-dir '{tmp}'
instanceToGlyphs = $(_DSF_$(subst -,,$(subst -instance,,$(basename $(notdir $@)))))

define makeVars =
from glyphsLib import GSFont
for instance in GSFont("$(SOURCE)").instances: print("_DSI_{1}{0} = {3} {2}\n_DSF_{1}{0} = $(SOURCE)".format(instance.name.replace(" ", ""), instance.familyName.replace(" ", ""), instance.name, instance.familyName))
endef

_TMP := $(shell local tmp=$$(mktemp vars-XXXXXX.mk); echo $${tmp}; {$(foreach SOURCE,$(SOURCES_GLYPHS),$(PYTHON) -c '$(makeVars)';)} >> $${tmp})
$(eval $(file < $(_TMP)))
$(shell rm -f $(_TMP))

%.glyphs: %.ufo
	$(FONTMAKE) $(FONTMAKEFLAGS) -u $< -o glyphs --output-path $@

# %.ufo: %.glyphs
#     $(FONTMAKE) $(FONTMAKEFLAGS) -g $< -o ufo

%.designspace: %.glyphs
	echo MM $@

# Glyphs -> Varibale OTF

$(BUILDDIR)/%-VF-variable.otf: $(SOURCEDIR)/%.glyphs | $(BUILDDIR)
	$(FONTMAKE) $(FONTMAKEFLAGS) -g $< -o variable-cff2 --output-path $@

# Glyphs -> Varibale TTF

$(BUILDDIR)/%-VF-variable.ttf: $(SOURCEDIR)/%.glyphs | $(BUILDDIR)
	$(FONTMAKE) $(FONTMAKEFLAGS) -g $< -o variable --output-path $@

# Glyphs -> Static OTF

define otf_instance_template ?=

$$(BUILDDIR)/$1-%-instance.otf: $$$$(instanceToGlyphs) | $$(BUILDDIR)
	$$(FONTMAKE) $$(FONTMAKEFLAGS) -g $$< -i "$$(_DSI_$1$$*)" -o otf --output-path $$@

endef

# Glyphs -> Static TTF

define ttf_instance_template ?=

$$(BUILDDIR)/$1-%-instance.ttf: $$$$(instanceToGlyphs) | $$(BUILDDIR)
	$$(FONTMAKE) $$(FONTMAKEFLAGS) -g $$< -i "$$(_DSI_$1$$*)" -o ttf --output-path $$@

endef
