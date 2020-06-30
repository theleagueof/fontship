licensedir = $(datarootdir)/licenses/fontship
datadir = $(datarootdir)/fontship

bin_SCRIPTS = fontship
python_PYTHON = fontship.py
dist_doc_DATA = README.md
dist_license_DATA = LICENSE
dist_data_DATA = src/rules.mk src/functions.mk src/rules-glyphs.mk src/rules-sfd.mk src/rules-ufo.mk

CLEANFILES = $(bin_SCRIPTS)

dist-hook:
	echo $(VERSION) > $(distdir)/.tarball-version

.PHONY: docker
docker: Dockerfile
	docker build \
		--build-arg VCS_REF="$(VERSION)" \
		--tag theleagueof/fontship:HEAD \
		./
