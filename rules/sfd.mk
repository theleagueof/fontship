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
