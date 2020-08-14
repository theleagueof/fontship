%.sfd: $(BUILDDIR)/$$(*F)-normalized.sfd $(BUILDDIR)/last-commit
	cp $< $@

$(BUILDDIR)/%-normalized.sfd: force | $(BUILDDIR)
	$(SFDNORMALIZE) $(SOURCEDIR)/$(*F).sfd $@
