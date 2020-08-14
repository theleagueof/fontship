%.sfd: $(BUILDDIR)/$$(*F)-normalized.sfd $(BUILDDIR)/last-commit
	cp $< $@

$(BUILDDIR)/%-normalized.sfd: force | $(BUILDDIR)
	$(SFDNORMALIZE) $(SOURCEDIR)/$(*F).sfd $@

check: $(foreach SFD,$(filter %.sfd,$(SOURCES)),$(SFD)-check)

.PHONY: %-.sfd-check
$(SOURCEDIR)/%.sfd-check: $(BUILDDIR)/%-normalized.sfd
	cmp $< $(SOURCEDIR)/$*.sfd
