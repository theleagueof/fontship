ACLOCAL_AMFLAGS = -I build-aux
AM_DISTCHECK_CONFIGURE_FLAGS = --enable-developer-mode

.ONESHELL:
.SECONDARY:
.SECONDEXPANSION:
.DELETE_ON_ERROR:

docdir = $(datarootdir)/doc/$(TRANSFORMED_PACKAGE_NAME)
licensedir = $(datarootdir)/licenses/$(TRANSFORMED_PACKAGE_NAME)
datadir = $(datarootdir)/$(TRANSFORMED_PACKAGE_NAME)
pkgdatadir = $(datadir)

dist_doc_DATA = README.md CHANGELOG.md
dist_license_DATA = LICENSE.md
dist_man_MANS = fontship.1
nobase_data_DATA = rules/fontship.mk
nobase_dist_data_DATA = rules/rules.mk rules/functions.mk rules/glyphs.mk rules/sfd.mk rules/ufo.mk
_fontship_libs = src/lib.rs src/cli.rs src/config.rs src/i18n.rs
_fontship_modules = src/make/mod.rs src/setup/mod.rs src/status/mod.rs
_fontship_assets = assets/en-US/cli.ftl
bin_PROGRAMS = fontship
fontship_SOURCES = src/main.rs $(_fontship_libs) $(_fontship_modules) $(_fontship_assets)
EXTRA_fontship_SOURCES = Cargo.lock
EXTRA_DIST = requirements.txt
EXTRA_DIST += build-aux/action-updater.js build-aux/cargo-updater.js build-aux/git-version-gen
EXTRA_DIST += Dockerfile build-aux/bootstrap-docker.sh hooks/build

BUILT_SOURCES =

CLEANFILES =

DISTCLEANFILES = @AMINCLUDE@

# A classical use of the autoconf-archive include macro would expand
# INC_AMINCLUDE here, but the perl script that inlines include statements
# runs before the automake that organizes logic and performs substitution.
# Consequentially with a substitution here it becomes impossible to use
# automake conditionals and substitutions in the included Makefile fragments.
# By entering the expanded value directly we are ready in time for the inlining
# functionality and hence can use conditionals in included makefile fragments.
include $(top_srcdir)/aminclude.am

CLEANFILES += $(bin_PROGRAMS)

.PHONY: clean-embedded-assets
clean-embedded-assets:
	[[ ! -e .git  ]] || $(GIT) clean -dxf assets

dist: fontship-$(VERSION).md

_svg_cleanup = select-all;object-to-path;vacuum-defs
_scour_args = --quiet --set-precision=4 --remove-metadata --enable-id-stripping --strip-xml-prolog --strip-xml-space --no-line-breaks --no-renderer-workaround

.PHONY: media
media: media/logo.svg media/emblum.svg media/icon.svg media_badge

media/logo.svg: media/logo-source.svg
	inkscape --batch-process \
		--actions "select-by-id:F;EditDelete;$(_svg_cleanup)" \
		$< -o $@
	scour $(_scour_args) $@ /dev/stdout | sponge $@

media/emblum.svg: media/logo-source.svg
	inkscape --batch-process \
		--actions "select-by-id:Fontship;EditDelete;select-by-id:truck;FitCanvasToSelection;$(_svg_cleanup)" \
		$< -o $@
	scour $(_scour_args) $@ /dev/stdout | sponge $@

media/icon.svg: media/logo-source.svg
	inkscape --batch-process \
		--actions "select-by-id:F,Fontship;EditDelete;select-by-id:truck;FitCanvasToSelection;select-by-id:cargo;object-set-attribute:fill,#000;$(_svg_cleanup)" \
		$< -o $@
	scour $(_scour_args) $@ /dev/stdout | sponge $@

media/badge.svg: media/logo-source.svg
	inkscape --batch-process \
		--actions "select-by-id:F,Fontship;EditDelete;select-by-id:truck;FitCanvasToSelection;$(_svg_cleanup);select-all;object-set-attribute:stroke,#FFF;object-set-attribute:fill,#FFF" \
		$< -o $@
	scour $(_scour_args) $@ /dev/stdout | sponge $@

.PHONY: media_badge
media_badge: media/badge.svg
	@echo =================
	@svgo --datauri base64 --multipass --quiet -i $< -o -
	@echo =================

dist: fontship-$(VERSION).md

fontship-%.md: CHANGELOG.md
	$(SED) -e '/\.\.\.v$*/,/\.\.\.v/!d' $< | \
		$(SED) -e '1,3d;N;$$!P;$$!D;$$d' > $@

PHONY_DEVELOPER_TARGETS  = lint checkmake ruff
PHONY_DEVELOPER_TARGETS += tagrelease release-preview release
PHONY_DEVELOPER_TARGETS += docker docker-dep-check docker-ghcr-to-hub docker-build-push
.PHONY: $(PHONY_DEVELOPER_TARGETS)

if DEVELOPER_MODE

lint: checkmake ruff ruff-format

checkmake:
	$(GIT) ls-files 'rules/*.mk' 'rules/*.mk.in' | $(XARGS) -n1 checkmake

ruff:
	$(GIT) ls-files '*.py' '*.py.in' | $(XARGS) $(RUFF) check

ruff-format:
	$(GIT) ls-files '*.py' '*.py.in' | $(XARGS) $(RUFF) format --check

RELTYPE ?=

tagrelease:
	test -z $$($(GIT) tag --points-at HEAD) || \
	$(GIT) diff-index --quiet --cached HEAD && \
	$(GIT) diff-files --quiet && \
	$(NPM) run release --preMajor $(and $(RELTYPE),--release-as $(RELTYPE))

release-preview:
	$(NPM) run release --preMajor --dry-run $(and $(RELTYPE),--release-as $(RELTYPE))

release: tagrelease

export GHCR_REGISTRY ?= ghcr.io
export GHCR_REPO ?= sile-typesetter/$(TRANSFORMED_PACKAGE_NAME)

export DOCKER_REGISTRY ?= docker.io
export DOCKER_REPO ?= theleagueof/$(TRANSFORMED_PACKAGE_NAME)
export DOCKER_TAG ?= HEAD

docker: Dockerfile hooks/build .version
	./hooks/build $(VERSION)

docker-dep-check: .docker_deps .aur_deps
	$(DIFF) -u $^

CLEANFILES += .docker_deps
.docker_deps: hooks/build
	$(SHELL) -c 'source <($(SED) -nE "/^(RUN|'"'"')/{s/.*=/echo /;p}" $<)' | \
		$(TR) ' ' '\n' | \
		$(SORT) > $@

CLEANFILES += .aur_deps
.aur_deps:
	$(CURL) -Ls 'https://aur.archlinux.org/cgit/aur.git/plain/.SRCINFO?h=fontship-git' | \
		$(SED) -nE '/\bdepends =/{s/.*= //;p}' | \
		$(GREP) -v 'so.$$' | \
		$(SORT) > $@

docker-ghcr-to-hub:
	$(DOCKER) pull $(GHCR_REGISTRY)/$(GHCR_REPO):$(DOCKER_TAG)
	$(DOCKER) tag  $(GHCR_REGISTRY)/$(GHCR_REPO):$(DOCKER_TAG) $(DOCKER_REGISTRY)/$(DOCKER_REPO):$(DOCKER_TAG)

else !DEVELOPER_MODE

$(PHONY_DEVELOPER_TARGETS):
	@: $(error "Please reconfigure using --enable-developer-mode to use developer tooling")

endif !DEVELOPER_MODE
