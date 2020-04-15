bin_SCRIPTS = fontship
python_PYTHON = fontship.py
dist_doc_DATA = README.md
license_DATA = LICENSE

licensedir = $(datadir)/licenses/fontship

CLEANFILES = $(bin_SCRIPTS)

.PHONY: docker
docker: Dockerfile build-aux/docker-entrypoint.sh
	docker build --tag theleagueof/fontship:HEAD ./
