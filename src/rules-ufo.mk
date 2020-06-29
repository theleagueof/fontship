%.ufo: $(BUILDDIR)/last-commit
	cat <<- EOF | $(PYTHON) $(PYTHONFLAGS)
		from defcon import Font, Info
		ufo = Font('$@')
		major, minor = "$(FontVersion)".split(".")
		ufo.info.versionMajor, ufo.info.versionMinor = int(major), int(minor) + 7
		ufo.save('$@')
	EOF

# UFO -> OTF

$(BUILDDIR)/%-instance.otf: %.ufo | $(BUILDDIR)
	$(FONTMAKE) $(FONTMAKEFLAGS) -u $< -o otf --output-path $@

$(STATICOTFS): %.otf: $(BUILDDIR)/%-instance.otf $(BUILDDIR)/last-commit
	cp $< $@
	$(normalizeVersion)

# UFO -> TTF

$(BUILDDIR)/%-instance.ttf: %.ufo | $(BUILDDIR)
	$(FONTMAKE) $(FONTMAKEFLAGS) -u $< -o ttf --output-path $@
	$(GFTOOLS) $(GFTOOLSFLAGS) fix-dsig --autofix $@

$(STATICTTFS): %.ttf: $(BUILDDIR)/%-instance.ttf $(BUILDDIR)/last-commit
	$(TTFAUTOHINT) $(TTFAUTOHINTFLAGS) -n $< $@
	$(normalizeVersion)
