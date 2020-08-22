%.ufo: $(BUILDDIR)/last-commit
	cat <<- EOF | $(PYTHON) $(PYTHONFLAGS)
		from defcon import Font, Info
		ufo = Font('$@')
		major, minor = "$(FontVersion)".split(".")
		ufo.info.versionMajor, ufo.info.versionMinor = int(major), int(minor) + 7
		ufo.save('$@')
	EOF

# UFO -> OTF

define otf_instance_template ?=
$$(BUILDDIR)/$1-%-instance.otf: $(SOURCEDIR)/$1-%.ufo | $$(BUILDDIR)
	$$(FONTMAKE) $$(FONTMAKEFLAGS) -u $$< -o otf --output-path $$@
endef

# UFO -> TTF

define ttf_instance_template ?=
$$(BUILDDIR)/$1-%-instance.ttf: $(SOURCEDIR)/$1-%.ufo | $$(BUILDDIR)
	$$(FONTMAKE) $$(FONTMAKEFLAGS) -u $$< -o ttf --output-path $$@
	$$(GFTOOLS) $$(GFTOOLSFLAGS) fix-dsig --autofix $$@
endef
