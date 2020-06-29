FONTMAKEFLAGS += --master-dir '{tmp}' --instance-dir '{tmp}'

%.glyphs: %.ufo
	$(FONTMAKE) $(FONTMAKEFLAGS) -u $< -o glyphs --output-path $@

# %.ufo: %.glyphs
#     $(FONTMAKE) $(FONTMAKEFLAGS) -g $< -o ufo

%.designspace: %.glyphs
	echo MM $@

# Glyphs -> Varibale OTF

$(BUILDDIR)/%-VF-variable.otf: %.glyphs | $(BUILDDIR)
	$(FONTMAKE) $(FONTMAKEFLAGS) -g $< -o variable-cff2 --output-path $@

$(VARIABLEOTFS): %.otf: $(BUILDDIR)/%-variable.otf $(BUILDDIR)/last-commit
	cp $< $@
	$(normalizeVersion)

# Glyphs -> Varibale TTF

$(BUILDDIR)/%-VF-variable.ttf: %.glyphs | $(BUILDDIR)
	$(FONTMAKE) $(FONTMAKEFLAGS) -g $< -o variable --output-path $@
	$(GFTOOLS) $(GFTOOLSFLAGS) fix-dsig --autofix $@

$(BUILDDIR)/%-unhinted.ttf: $(BUILDDIR)/%-variable.ttf
	$(GFTOOLS) $(GFTOOLSFLAGS) fix-nonhinting $< $@

$(BUILDDIR)/%-nomvar.ttx: $(BUILDDIR)/%.ttf
	$(TTX) $(TTXFLAGS) -o $@ -f -x "MVAR" $<

$(BUILDDIR)/%.ttf: $(BUILDDIR)/%.ttx
	$(TTX) $(TTXFLAGS) -o $@ $<

$(VARIABLETTFS): %.ttf: $(BUILDDIR)/%-unhinted-nomvar.ttf $(BUILDDIR)/last-commit
	cp $< $@
	$(normalizeVersion)

# Glyphs -> Static OTF

$(BUILDDIR)/$(FontBase)-%-instance.otf: $(FontBase).glyphs | $(BUILDDIR)
	$(FONTMAKE) $(FONTMAKEFLAGS) -g $< -i "$(FamilyName) $*" -o otf --output-path $@

$(STATICOTFS): %.otf: $(BUILDDIR)/%-instance.otf $(BUILDDIR)/last-commit
	cp $< $@
	$(normalizeVersion)

# Glyphs -> Static TTF

$(BUILDDIR)/$(FontBase)-%-instance.ttf: $(FontBase).glyphs | $(BUILDDIR)
	$(FONTMAKE) $(FONTMAKEFLAGS) -g $< -i "$(FamilyName) $*" -o ttf --output-path $@
	$(GFTOOLS) $(GFTOOLSFLAGS) fix-dsig --autofix $@

$(STATICTTFS): %.ttf: $(BUILDDIR)/%-instance.ttf $(BUILDDIR)/last-commit
	$(TTFAUTOHINT) $(TTFAUTOHINTFLAGS) -n $< $@
	$(normalizeVersion)
