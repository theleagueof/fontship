licensedir = $(datarootdir)/licenses/fontship
datadir = $(datarootdir)/fontship

bin_SCRIPTS = fontship
python_PYTHON = fontship.py
dist_doc_DATA = README.md CHANGELOG.md
dist_license_DATA = LICENSE
dist_data_DATA = src/rules.mk src/functions.mk src/rules-glyphs.mk src/rules-sfd.mk src/rules-ufo.mk
EXTRA_DIST = .version Dockerfile

BUILT_SOURCES = .version

CLEANFILES = $(BUILT_SOURCES) $(bin_SCRIPTS)

.version: $(shell test -e .git && awk '{print ".git/" $$2}' .git/HEAD)
	mv $@{,-prev} 2>/dev/null || touch $@-prev
	( test -e .git && ./build-aux/git-version-gen .tarball-version || echo $(VERSION) ) > $@
	cmp -s $@{,-prev} || autoreconf configure.ac --force -W none

dist-hook:
	echo $(VERSION) > $(distdir)/.tarball-version

RELTYPE ?=

.PHONY: tagrelease
tagrelease:
	test -z $$(git tag --points-at HEAD) || exit 0 # end if we are already on a release tag
	git diff-index --quiet --cached HEAD || exit 1 # die if anything staged but not committed
	git diff-files --quiet || exit 1 # die if any tracked files have unstagged changes
	npm run release -- $(and $(RELTYPE),--release-as $(RELTYPE))

.PHONY: prerelease
prerelease: all

.PHONY: release-preview
release-preview:
	npm run release -- --dry-run $(and $(RELTYPE),--release-as $(RELTYPE))

.PHONY: release
release: tagrelease


.PHONY: docker
docker: Dockerfile
	docker build \
		--build-arg VCS_REF="$(VERSION)" \
		--tag theleagueof/fontship:HEAD \
		./
