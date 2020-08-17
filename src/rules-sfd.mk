needs_normalization = $(shell cmp -s $*.sfd $(BUILDDIR)/$(*F)-normalized.sfd || echo force)

%.sfd: $$(needs_normalization)
	git diff-files --quiet -- $@ || exit 1 # die if this file has uncommitted changes
	local norm=$(BUILDDIR)/$(*F)-normalized.sfd
	$(SFDNORMALIZE) $@ $$norm
	cp $$norm $@

$(BUILDDIR)/%-normalized.sfd: %.sfd | $(BUILDDIR)
	$(SFDNORMALIZE) $(SOURCEDIR)/$(*F).sfd $@

check: $(foreach SFD,$(filter %.sfd,$(SOURCES)),$(SFD)-check)

.PHONY: %-.sfd-check
$(SOURCEDIR)/%.sfd-check: $(BUILDDIR)/%-normalized.sfd
	cmp $< $(SOURCEDIR)/$*.sfd
