$(and $(word 2,$(MAKEFILE_LIST)),$(error This is not the makefile you should include in your project to run Fontship, please use 'rules/fontship.mk' instead.))

ACLOCAL_AMFLAGS = -I build-aux

.ONESHELL:
.SECONDARY:
.SECONDEXPANSION:
.DELETE_ON_ERROR:

licensedir = $(datarootdir)/licenses/$(TRANSFORMED_PACKAGE_NAME)
docdir = $(datarootdir)/doc/$(TRANSFORMED_PACKAGE_NAME)
datadir = $(datarootdir)/$(TRANSFORMED_PACKAGE_NAME)
pkgdatadir = $(datadir)

pkgdata_SCRIPTS = make-shell.zsh
dist_doc_DATA = README.md CHANGELOG.md
dist_license_DATA = LICENSE
dist_man_MANS = fontship.1
nobase_data_DATA = rules/fontship.mk
nobase_dist_data_DATA = rules/rules.mk rules/functions.mk rules/glyphs.mk rules/sfd.mk rules/ufo.mk
bin_PROGRAMS = fontship
_fontship_libs = src/lib.rs src/cli.rs src/config.rs src/i18n.rs
_fontship_modules = src/make/mod.rs src/setup/mod.rs src/status/mod.rs
_fontship_assets = assets/en-US/cli.ftl
fontship_SOURCES = Cargo.toml build.rs src/main.rs $(_fontship_libs) $(_fontship_modules) $(_fontship_assets)
EXTRA_fontship_SOURCES = Cargo.lock
EXTRA_DIST = requirements.txt
EXTRA_DIST += build-aux/cargo-updater.js build-aux/git-version-gen
EXTRA_DIST += Dockerfile build-aux/bootstrap-docker.sh build-aux/docker-glibc-workaround.sh hooks/build

BUILT_SOURCES = .version
CLEANFILES = $(BUILT_SOURCES) .version-prev $(bin_PROGRAMS)

if ENABLE_BASH_COMPLETION
bashcompletiondir = $(BASH_COMPLETION_DIR)
nodist_bashcompletion_DATA = $(COMPLETIONS_OUT_DIR)/$(TRANSFORMED_PACKAGE_NAME)
endif

if ENABLE_FISH_COMPLETION
fishcompletiondir = $(FISH_COMPLETION_DIR)
nodist_fishcompletion_DATA = $(COMPLETIONS_OUT_DIR)/$(TRANSFORMED_PACKAGE_NAME).fish
endif

if ENABLE_ZSH_COMPLETION
zshcompletiondir = $(ZSH_COMPLETION_DIR)
nodist_zshcompletion_DATA = $(COMPLETIONS_OUT_DIR)/_$(TRANSFORMED_PACKAGE_NAME)
endif

if DEBUG_RELEASE
CARGO_RELEASE_ARGS=--all-features
_TARGETDIR=debug
else
CARGO_RELEASE_ARGS=--release --locked --all-features
_TARGETDIR=release
endif

export FONTSHIP_VERSION = v$(VERSION)

# Leave some tips for cargo to use so CLI knows where it is
export CONFIGURE_PREFIX = $(prefix)/
export CONFIGURE_DATADIR = $(datadir)/
export CONFIGURE_BINDIR = $(bindir)/

CARGO_VERBOSE = $(cargo_verbose_$(V))
cargo_verbose_ = $(cargo_verbose_$(AM_DEFAULT_VERBOSITY))
cargo_verbose_0 =
cargo_verbose_1 = --verbose

CARGO_TARGET = target/$(_TARGETDIR)/fontship
COMPLETIONS_OUT_DIR = target/$(_TARGETDIR)/completions

fontship$(EXEEXT): $(CARGO_TARGET)
	cp -bf $< $@

$(COMPLETIONS_OUT_DIR)/$(TRANSFORMED_PACKAGE_NAME): $(CARGO_TARGET)
	cp -bf $(COMPLETIONS_OUT_DIR)/$(PACKAGE_NAME).bash $@

$(COMPLETIONS_OUT_DIR)/$(TRANSFORMED_PACKAGE_NAME).elv: $(CARGO_TARGET)
	cp -bf $(COMPLETIONS_OUT_DIR)/$(PACKAGE_NAME).elv $@

$(COMPLETIONS_OUT_DIR)/$(TRANSFORMED_PACKAGE_NAME).fish: $(CARGO_TARGET)
	cp -bf $(COMPLETIONS_OUT_DIR)/$(PACKAGE_NAME).fish $@

$(COMPLETIONS_OUT_DIR)/_$(TRANSFORMED_PACKAGE_NAME).ps1: $(CARGO_TARGET)
	cp -bf $(COMPLETIONS_OUT_DIR)/_$(PACKAGE_NAME).ps1 $@

$(COMPLETIONS_OUT_DIR)/_$(TRANSFORMED_PACKAGE_NAME): $(CARGO_TARGET)
	cp -bf $(COMPLETIONS_OUT_DIR)/_$(PACKAGE_NAME) $@

$(CARGO_TARGET): $(fontship_SOURCES) clean-embedded-assets
	cargo build $(CARGO_VERBOSE) $(CARGO_RELEASE_ARGS)

.version: $(shell $(AWK) '{print ".git/" $$2}' .git/HEAD 2>/dev/null ||:)
	[ -e "$@" ] && mv "$@" "$@-prev" || $(if $<,touch,cp "$(srcdir)/.tarball-version") "$@-prev"
	$(if $<,./build-aux/git-version-gen "$(srcdir)/.tarball-version",printf "$(VERSION)") > "$@"
	$(CMP) -s "$@" "$@-prev" || autoreconf configure.ac --force

.PHONY: clean-embedded-assets
clean-embedded-assets:
	[[ ! -e .git  ]] || git clean -dxf assets

dist: fontship-$(VERSION).md

dist-hook:
	printf "$(VERSION)" > "$(distdir)/.tarball-version"

check-local: cargo-test check-local-version

check-local-version: $(PACKAGE_NAME) | .version

cargo-test: $(PACKAGE_NAME)
	cargo test --locked

clean-local:
	cargo clean

RELTYPE ?=

.PHONY: tagrelease
tagrelease:
	test -z $$(git tag --points-at HEAD) || \
	git diff-index --quiet --cached HEAD && \
	git diff-files --quiet && \
	npm run release -- $(and $(RELTYPE),--release-as $(RELTYPE))

.PHONY: release-preview
release-preview:
	npm run release -- --dry-run $(and $(RELTYPE),--release-as $(RELTYPE))

.PHONY: release
release: tagrelease

fontship-%.md: CHANGELOG.md
	sed -e '/\.\.\.v$*/,/\.\.\.v/!d' $< | \
		sed -e '1,3d;N;$$!P;$$!D;$$d' > $@

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

.PHONY: docker
docker: Dockerfile hooks/build .version
	IMAGE_NAME=theleagueof/$(_fontship):HEAD ./hooks/build $(VERSION)
