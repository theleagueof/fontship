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
EXTRA_DIST += build-aux/action-updater.js build-aux/cargo-updater.js build-aux/git-version-gen
EXTRA_DIST += Dockerfile build-aux/bootstrap-docker.sh build-aux/docker-glibc-workaround.sh hooks/build

BUILT_SOURCES = .version
CLEANFILES = $(BUILT_SOURCES) .version-prev $(bin_PROGRAMS) fontship-$(VERSION).md

if DEBUG_RELEASE
CARGO_RELEASE_ARGS=--all-features
_TARGETDIR=debug
else
CARGO_RELEASE_ARGS=--release --locked --all-features
_TARGETDIR=release
endif

CARGO_ENV = CARGO_TARGET_DIR=@abs_top_builddir@/target
RUST_BIN = @abs_top_builddir@/target/@RUST_TARGET_SUBDIR@/$(PACKAGE_NAME)
_RUST_OUT = @abs_top_builddir@/target/@RUST_TARGET_SUBDIR@/.cargo_out_dir
COMPLETIONS_OUT_DIR = completions

if ENABLE_BASH_COMPLETION
bashcompletiondir = $(BASH_COMPLETION_DIR)
nodist_bashcompletion_DATA = $(COMPLETIONS_OUT_DIR)/$(TRANSFORMED_PACKAGE_NAME)
CLEANFILES += $(nodist_bashcompletion_DATA)
endif

if ENABLE_FISH_COMPLETION
fishcompletiondir = $(FISH_COMPLETION_DIR)
nodist_fishcompletion_DATA = $(COMPLETIONS_OUT_DIR)/$(TRANSFORMED_PACKAGE_NAME).fish
CLEANFILES += $(nodist_fishcompletion_DATA)
endif

if ENABLE_ZSH_COMPLETION
zshcompletiondir = $(ZSH_COMPLETION_DIR)
nodist_zshcompletion_DATA = $(COMPLETIONS_OUT_DIR)/_$(TRANSFORMED_PACKAGE_NAME)
CLEANFILES += $(nodist_zshcompletion_DATA)
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

$(COMPLETIONS_OUT_DIR):
	mkdir -p $@

fontship$(EXEEXT): $(RUST_BIN)
	cp -bf $< $@

$(COMPLETIONS_OUT_DIR)/$(TRANSFORMED_PACKAGE_NAME): $(RUST_BIN) | $(COMPLETIONS_OUT_DIR)
	cp -bf $$(cat $(_RUST_OUT))/$(COMPLETIONS_OUT_DIR)/$(PACKAGE_NAME).bash $@

$(COMPLETIONS_OUT_DIR)/$(TRANSFORMED_PACKAGE_NAME).elv: $(RUST_BIN) | $(COMPLETIONS_OUT_DIR)
	cp -bf $$(cat $(_RUST_OUT))/$(COMPLETIONS_OUT_DIR)/$(PACKAGE_NAME).elv $@

$(COMPLETIONS_OUT_DIR)/$(TRANSFORMED_PACKAGE_NAME).fish: $(RUST_BIN) | $(COMPLETIONS_OUT_DIR)
	cp -bf $$(cat $(_RUST_OUT))/$(COMPLETIONS_OUT_DIR)/$(PACKAGE_NAME).fish $@

$(COMPLETIONS_OUT_DIR)/_$(TRANSFORMED_PACKAGE_NAME).ps1: $(RUST_BIN) | $(COMPLETIONS_OUT_DIR)
	cp -bf $$(cat $(_RUST_OUT))/$(COMPLETIONS_OUT_DIR)/_$(PACKAGE_NAME).ps1 $@

$(COMPLETIONS_OUT_DIR)/_$(TRANSFORMED_PACKAGE_NAME): $(RUST_BIN) | $(COMPLETIONS_OUT_DIR)
	cp -bf $$(cat $(_RUST_OUT))/$(COMPLETIONS_OUT_DIR)/_$(PACKAGE_NAME) $@

$(_RUST_OUT) $(RUST_BIN): $(fontship_SOURCES) $(EXTRA_fontship_SOURCES) clean-embedded-assets
	cd $(top_srcdir)
	$(CARGO_ENV) $(CARGO) build $(CARGO_VERBOSE) $(CARGO_RELEASE_ARGS)
	$(CARGO_ENV) $(CARGO) build --quiet --message-format=json $(CARGO_RELEASE_ARGS) |
		$(JQ) -sr 'map(select(.reason == "build-script-executed")) | last | .out_dir' > $(_RUST_OUT)

.version: $(shell $(AWK) '{print ".git/" $$2}' .git/HEAD 2>/dev/null ||:)
	[ -e "$@" ] && mv "$@" "$@-prev" || $(if $<,touch,cp "$(srcdir)/.tarball-version") "$@-prev"
	$(if $<,./build-aux/git-version-gen "$(srcdir)/.tarball-version",printf "$(VERSION)") > "$@"
	$(CMP) -s "$@" "$@-prev" || autoreconf configure.ac --force

.PHONY: clean-embedded-assets
clean-embedded-assets:
	[[ ! -e .git  ]] || $(GIT) clean -dxf assets

dist: fontship-$(VERSION).md

dist-hook:
	printf "$(VERSION)" > "$(distdir)/.tarball-version"

clean-local:
	cd $(top_srcdir)
	$(CARGO_ENV) $(CARGO) clean

check-local: cargo-test check-version

cargo-test: $(PACKAGE_NAME)$(EXEEXT)
	cd $(srcdir)
	$(CARGO_ENV) $(CARGO) test --locked

check-version: $(PACKAGE_NAME)$(EXEEXT) | .version
	./$< --version | $(GREP) -Ff $|

installcheck-local:
	./$(TRANSFORMED_PACKAGE_NAME) --version

.PHONY: lint
lint: rustfmt clippy

.PHONY: rustfmt
rustfmt:
	$(GIT) ls-files '*.rs' | $(XARGS) rustfmt --check

.PHONY: clippy
clippy:
	cd $(srcdir)
	$(CARGO_ENV) $(CARGO) clippy -- -D warnings

RELTYPE ?=

.PHONY: tagrelease
tagrelease:
	test -z $$($(GIT) tag --points-at HEAD) || \
	$(GIT) diff-index --quiet --cached HEAD && \
	$(GIT) diff-files --quiet && \
	npm run release $(and $(RELTYPE),--release-as $(RELTYPE))

.PHONY: release-preview
release-preview:
	npm run release -- --dry-run $(and $(RELTYPE),--release-as $(RELTYPE))

.PHONY: release
release: tagrelease

fontship-%.md: CHANGELOG.md
	$(SED) -e '/\.\.\.v$*/,/\.\.\.v/!d' $< | \
		$(SED) -e '1,3d;N;$$!P;$$!D;$$d' > $@

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

export DOCKER_REGISTRY ?= docker.io
export DOCKER_REPO ?= theleagueof/$(TRANSFORMED_PACKAGE_NAME)
export DOCKER_TAG ?= HEAD

.PHONY: docker
docker: Dockerfile hooks/build .version
	./hooks/build $(VERSION)

.PHONY: docker-build-push
docker-build-push: docker
	docker tag $(DOCKER_REPO):$(DOCKER_TAG) $(DOCKER_REGISTRY)/$(DOCKER_REPO):$(DOCKER_TAG)
	test -z "$(DOCKER_PAT)" || \
		docker login https://$(DOCKER_REGISTRY) -u $(DOCKER_USERNAME) -p $(DOCKER_PAT)
	docker push $(DOCKER_REGISTRY)/$(DOCKER_REPO):$(DOCKER_TAG)
	if [[ "$(DOCKER_TAG)" == v*.*.* ]]; then \
		tag=$(DOCKER_TAG) ;\
		docker tag $(DOCKER_REPO):$(DOCKER_TAG) $(DOCKER_REGISTRY)/$(DOCKER_REPO):latest ;\
		docker tag $(DOCKER_REPO):$(DOCKER_TAG) $(DOCKER_REGISTRY)/$(DOCKER_REPO):$${tag//.*} ;\
		docker push $(DOCKER_REGISTRY)/$(DOCKER_REPO):latest ;\
		docker push $(DOCKER_REGISTRY)/$(DOCKER_REPO):$${tag//.*} ;\
	fi
