$(SOURCEDIR)/%.sfd: $$(call ifTrue,$$(NORMALIZE_MODE),force) | $(BUILDDIR)
	local _normalized=$(BUILDDIR)/$(*F)-normalized.sfd
	$(SFDNORMALIZE) $@ $${_normalized}
	cp $${_normalized} $@

$(BUILDDIR)/%-normalized.sfd: $(SOURCEDIR)/%.sfd | $(BUILDDIR)
	$(SFDNORMALIZE) $< $@

.PHONY: $(SOURCEDIR)/%.sfd-check
$(SOURCEDIR)/%.sfd-check: $(SOURCEDIR)/%.sfd $(BUILDDIR)/%-normalized.sfd
	cmp $^
