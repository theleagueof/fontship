sfdNormalize ?= $(SFDNORMALIZE) $(SFDNORMALIZEFLAGS) "$1" "$2"

$(SOURCEDIR)/%.sfd: $$(call ifTrue,$$(NORMALIZE_MODE),force) | $(BUILDDIR)
	local _normalized=$(BUILDDIR)/$(*F)-normalized.sfd
	$(call sfdNormalize,$@,$${_normalized})
	cp $${_normalized} $@

$(BUILDDIR)/%-normalized.sfd: $(SOURCEDIR)/%.sfd | $(BUILDDIR)
	$(call sfdNormalize,$<,$@)

.PHONY: $(SOURCEDIR)/%.sfd-check
$(SOURCEDIR)/%.sfd-check: $(SOURCEDIR)/%.sfd $(BUILDDIR)/%-normalized.sfd
	cmp $^

$(BUILDDIR)/%-normalized.ufo: $(BUILDDIR)/%-normalized.sfd | $(BUILDDIR)
	$(SFD2UFO) $(SFD2UFOFLAGS) --minimal $< $@

-include $(FONTSHIPDIR)/rules/ufo.mk
