licensedir = $(datarootdir)/licenses/fontship
datadir = $(datarootdir)/fontship

bin_SCRIPTS = fontship
python_PYTHON = fontship.py
dist_doc_DATA = README.md
dist_license_DATA = LICENSE
dist_data_DATA = src/rules.mk src/functions.mk src/rules-glyphs.mk src/rules-sfd.mk src/rules-ufo.mk
EXTRA_DIST = .version

BUILT_SOURCES = .version

CLEANFILES = $(bin_SCRIPTS)

.version: $(shell test -e .git && awk '{print ".git/" $$2}' .git/HEAD)
	mv $@{,-prev} 2>/dev/null || touch $@-prev
	( test -e .git && ./build-aux/git-version-gen .tarball-version || echo $(VERSION) ) > $@
	cmp -s $@{,-prev} || autoreconf configure.ac --force -W none

dist-hook:
	echo $(VERSION) > $(distdir)/.tarball-version

.PHONY: docker
docker: Dockerfile
	docker build \
		--build-arg VCS_REF="$(VERSION)" \
		--tag theleagueof/fontship:HEAD \
		./
