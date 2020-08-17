# Changelog

All notable changes to this project will be documented in this file. See [standard-version](https://github.com/conventional-changelog/standard-version) for commit guidelines.

### [0.2.1](https://github.com/theleagueof/fontship/compare/v0.2.0...v0.2.1) (2020-08-14)

* Fix automation so builds posted to Github Releases are automatic again.

## [0.2.0](https://github.com/theleagueof/fontship/compare/v0.1.1...v0.2.0) (2020-08-14)

* Setup separate build paths for different canonical sources (Glyphs, UFO, Fontforge, etc.). This is a lot more flexible than assuming fonts being build from any source need the same fixup treatment along the way. Also it gives a place to hook into and use Fontship's overall machinery while using a completely custom set of rules to do the actual font generation if for some reason the default commands aren't right.
* Add basic rules to generate from single instance UFO sources.
* Expand the CLI options a little bit with some output control. For example try `fontship -q make` for a much less noisy build cycle.
* Make sure local system installations check for the tools that will be needed at runtime (not used for Docker, etc. but useful for system installations).
* Add basic repository detection to `fontship status`.
* Leverage more `gftools fix-*` routines to cleanup generated fonts.

### [0.1.1](https://github.com/theleagueof/fontship/compare/v0.1.0...v0.1.1) (2020-08-14)

* Cleanup files generated during build process and tidy them away into a build dir.
* Allow local projects to and their own project local rules file.
* Package any found documentation or license files in distribution archives.
* Flesh out CI usage documentation.
* Suppress some unnecessary verbosity during build process.
* Make all system tools configurable.
* Update to latest Python font tooling available upstream.
* Fix parallel build issues.
* Allow building fonts in groups by either format (ttf, otf, etc.) or type (static, variable).

## [0.1.0](https://github.com/theleagueof/fontship/compare/v0.0.5...v0.1.0) (2020-08-14)

* Make it usable as a Github Action
* Cleanup layout of distribution archives

### [0.0.5](https://github.com/theleagueof/fontship/compare/v0.0.4...v0.0.5) (2020-08-14)

* Rename *Font Name* → *Family Name* to match use in font ecosystem tooling.
* Document how to set the Family Name for Docker builds (temporary, but works).
* Fix issues with Docker dependencies.

### [0.0.4](https://github.com/theleagueof/fontship/compare/v0.0.3...v0.0.4) (2020-08-14)

* Add dependencies such as fonttools, fontmake, gftools, ttfautohint, some Python stuff, etc.
* Add stubs for more CLI commands.
* Refactor CLI for more future versatility.
* Allow use of Glyphs as canonical source
* Add rules to build TTF, OTF, WOFF, WOFF2, and variable TTF artifacts.

### [0.0.3](https://github.com/theleagueof/fontship/compare/v0.0.2...v0.0.3) (2020-08-14)

* Document Arch Linux install.
* Work around Docker Hub kernel issues.

### [0.0.2](https://github.com/theleagueof/fontship/compare/v0.0.1...v0.0.2) (2020-08-14)

* Split makefiles for things we package vs. what we are.
* Add status functions.
* Add some basic font format conversion rules.
* Setup CLI as dispatcher.
* Document dependencies.
* Add CI tooling to generate releases.

### [0.0.1](https://github.com/theleagueof/fontship/compare/v0.0.0...v0.0.1) (2020-08-14)

* Setup Docker image.
* Expand documentation (as project spec).
* Allow usage of Python scripts from any location.

### [0.0.0](https://github.com/theleagueof/fontship/compare/v0.0.0...v0.0.1) (2020-08-14)

* Start project boilerplate.
