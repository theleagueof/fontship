FONTMAKEFLAGS += --master-dir '{tmp}' --instance-dir '{tmp}'

%.glyphs: %.ufo
	$(FONTMAKE) $(FONTMAKEFLAGS) -u $< -o glyphs --output-path $@

# %.ufo: %.glyphs
#     $(FONTMAKE) $(FONTMAKEFLAGS) -g $< -o ufo

%.designspace: %.glyphs
	echo MM $@

# Glyphs -> Varibale OTF

$(BUILDDIR)/%-VF-variable.otf: $(SOURCEDIR)/%.glyphs | $(BUILDDIR)
	$(FONTMAKE) $(FONTMAKEFLAGS) -g $< -o variable-cff2 --output-path $@
	$(GFTOOLS) $(GFTOOLSFLAGS) fix-vf-meta $@
	$(GFTOOLS) $(GFTOOLSFLAGS) fix-unwanted-tables --tables MVAR $@ ||:
	$(GFTOOLS) $(GFTOOLSFLAGS) fix-dsig -f $@

$(VARIABLEOTFS): %.otf: $(BUILDDIR)/%-variable.otf $(BUILDDIR)/last-commit
	cp $< $@
	$(normalizeVersion)

# Glyphs -> Varibale TTF

$(BUILDDIR)/%-VF-variable.ttf: $(SOURCEDIR)/%.glyphs | $(BUILDDIR)
	$(FONTMAKE) $(FONTMAKEFLAGS) -g $< -o variable --output-path $@
	$(GFTOOLS) $(GFTOOLSFLAGS) fix-vf-meta $@
	$(GFTOOLS) $(GFTOOLSFLAGS) fix-unwanted-tables --tables MVAR $@ ||:
	$(GFTOOLS) $(GFTOOLSFLAGS) fix-dsig -f $@

$(BUILDDIR)/%-hinted.ttf: $(BUILDDIR)/%.ttf
	$(TTFAUTOHINT) $(TTFAUTOHINTFLAGS) -n $< $@

$(BUILDDIR)/%-hinted.ttf.fix: $(BUILDDIR)/%-hinted.ttf
	$(GFTOOLS) $(GFTOOLSFLAGS) fix-hinting $<
	$(GFTOOLS) $(GFTOOLSFLAGS) fix-gasp $@

$(VARIABLETTFS): %.ttf: $(BUILDDIR)/%-variable-hinted.ttf.fix $(BUILDDIR)/last-commit
	cp $< $@
	$(normalizeVersion)

# Glyphs -> Static OTF

$(BUILDDIR)/$(FontBase)-%-instance.otf: $(SOURCEDIR)/$(FontBase).glyphs | $(BUILDDIR)
	$(FONTMAKE) $(FONTMAKEFLAGS) -g $< -i "$(FamilyName) $*" -o otf --output-path $@
	$(GFTOOLS) $(GFTOOLSFLAGS) fix-dsig -f $@

$(STATICOTFS): %.otf: $(BUILDDIR)/%-instance.otf $(BUILDDIR)/last-commit
	cp $< $@
	$(normalizeVersion)

# Glyphs -> Static TTF

$(BUILDDIR)/$(FontBase)-%-instance.ttf: $(SOURCEDIR)/$(FontBase).glyphs | $(BUILDDIR)
	$(FONTMAKE) $(FONTMAKEFLAGS) -g $< -i "$(FamilyName) $*" -o ttf --output-path $@
	$(GFTOOLS) $(GFTOOLSFLAGS) fix-dsig -f $@

$(BUILDDIR)/%-hinted.ttf: $(BUILDDIR)/%-instance.ttf
	$(TTFAUTOHINT) $(TTFAUTOHINTFLAGS) -n $< $@

$(BUILDDIR)/%-hinted.ttf.fix: $(BUILDDIR)/%-hinted.ttf
	$(GFTOOLS) $(GFTOOLSFLAGS) fix-hinting $<

$(STATICTTFS): %.ttf: $(BUILDDIR)/%-hinted.ttf.fix $(BUILDDIR)/last-commit
	cp $< $@
	$(normalizeVersion)
