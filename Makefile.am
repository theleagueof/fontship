$(and $(word 2,$(MAKEFILE_LIST)),$(error This is not the makefile you should include in your project to run Fontship, please use 'rules/fontship.mk' instead.))

_fontship = $(shell sed -e "$(program_transform_name)" <<< fontship)

licensedir = $(datarootdir)/licenses/$(_fontship)
datadir = $(datarootdir)/$(_fontship)

dist_doc_DATA = README.md CHANGELOG.md
dist_man_MANS = $(_fontship).1
dist_license_DATA = LICENSE
nobase_dist_data_DATA = rules/fontship.mk rules/rules.mk rules/functions.mk rules/glyphs.mk rules/sfd.mk rules/ufo.mk
EXTRA_DIST = .version Dockerfile build-aux/cargo-updater.js

bin_PROGRAMS = fontship

_fontship_libs = src/lib.rs src/cli.rs src/config.rs src/i18n.rs
_fontship_modules = src/make/mod.rs src/setup/mod.rs src/status/mod.rs
_fontship_assets = assets/en-US/cli.ftl
fontship_SOURCES = Cargo.toml build.rs src/main.rs $(_fontship_libs) $(_fontship_modules) $(_fontship_assets)
EXTRA_fontship_SOURCES = Cargo.lock

BUILT_SOURCES = .version

CLEANFILES = $(BUILT_SOURCES) $(bin_PROGRAMS)

.version: $(shell test -e .git && awk '{print ".git/" $$2}' .git/HEAD)
	mv $@{,-prev} 2>/dev/null || touch $@-prev
	( test -e .git && ./build-aux/git-version-gen .tarball-version || echo $(VERSION) ) > $@
	cmp -s $@{,-prev} || autoreconf configure.ac --force -W none

if ENABLE_BASH_COMPLETION
bashcompletiondir = $(BASH_COMPLETION_DIR)
dist_bashcompletion_DATA = $(COMPLETIONS_OUT_DIR)/$(_fontship)
endif

if ENABLE_FISH_COMPLETION
fishcompletiondir = $(FISH_COMPLETION_DIR)
dist_fishcompletion_DATA = $(COMPLETIONS_OUT_DIR)/$(_fontship).fish
endif

if ENABLE_ZSH_COMPLETION
zshcompletiondir = $(ZSH_COMPLETION_DIR)
dist_zshcompletion_DATA = $(COMPLETIONS_OUT_DIR)/_$(_fontship)
endif

if DEBUG_RELEASE
CARGO_RELEASE_ARGS=--locked --all-features
else
CARGO_RELEASE_ARGS=--release --locked --all-features
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

CARGO_TARGET = target/release/fontship
COMPLETIONS_OUT_DIR = target/release/completions

fontship$(EXEEXT): $(CARGO_TARGET)
	cp -bf $< $@

$(COMPLETIONS_OUT_DIR)/$(_fontship): $(CARGO_TARGET)
	cp -bf $(COMPLETIONS_OUT_DIR)/fontship.bash $@

$(COMPLETIONS_OUT_DIR)/$(_fontship).elv: $(CARGO_TARGET)
	cp -bf $(COMPLETIONS_OUT_DIR)/fontship.elv $@

$(COMPLETIONS_OUT_DIR)/$(_fontship).fish: $(CARGO_TARGET)
	cp -bf $(COMPLETIONS_OUT_DIR)/fontship.fish $@

$(COMPLETIONS_OUT_DIR)/_$(_fontship).ps1: $(CARGO_TARGET)
	cp -bf $(COMPLETIONS_OUT_DIR)/_fontship.ps1 $@

$(COMPLETIONS_OUT_DIR)/_$(_fontship): $(CARGO_TARGET)
	cp -bf $(COMPLETIONS_OUT_DIR)/_fontship $@

$(CARGO_TARGET): $(fontship_SOURCES) clean-embedded-assets
	cargo build $(CARGO_VERBOSE) $(CARGO_RELEASE_ARGS)

.PHONY: clean-embedded-assets
clean-embedded-assets:
	[[ -d .git  ]] || exit 0
	git clean -dxf assets

dist: fontship-$(VERSION).md

dist-hook:
	echo $(VERSION) > $(distdir)/.tarball-version

check: selfcheck

.PHONY: selfcheck
selfcheck: $(_fontship) | $(BUILT_SOURCES)
	./$< --version | grep -Ff $(firstword $|)

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

fontship-%.md: CHANGELOG.md
	sed -e '/\.\.\.v$*/,/\.\.\.v/!d' $< | \
		sed -e '1,3d;N;$$!P;$$!D;$$d' > $@

.PHONY: docker
docker: Dockerfile
	docker build \
		--build-arg VCS_REF="$(VERSION)" \
		--tag theleagueof/fontship:HEAD \
		./
