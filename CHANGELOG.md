# Changelog

All notable changes to this project will be documented in this file. See [standard-version](https://github.com/conventional-changelog/standard-version) for commit guidelines.

### [0.4.3](https://github.com/theleagueof/fontship/compare/v0.4.2...v0.4.3) (2020-09-17)


### Bug Fixes

* **glyphs:** Enumerate all instances from sources even with spaces ([4b68de8](https://github.com/theleagueof/fontship/commit/4b68de8e106d3505ca310c80a582bb3b0ecc1d52))
* **glyphs:** Map all instance names back to source files ([a4d3fce](https://github.com/theleagueof/fontship/commit/a4d3fce386d8b16feadf5be2b13b174e7382f7dd))

### [0.4.2](https://github.com/theleagueof/fontship/compare/v0.4.1...v0.4.2) (2020-09-14)


### Features

* **rules:** Add mechanism to disable hinting ([#81](https://github.com/theleagueof/fontship/issues/81)) ([f65a96f](https://github.com/theleagueof/fontship/commit/f65a96fd676b74f4c5fa726007cad21732cf36bf))

### [0.4.1](https://github.com/theleagueof/fontship/compare/v0.4.0...v0.4.1) (2020-08-29)


### Features

* **build:** Find and package authors, contributors, and fontlog files ([#78](https://github.com/theleagueof/fontship/issues/78)) ([602af28](https://github.com/theleagueof/fontship/commit/602af2814534c687ac21e2be2fd5c7e1b7556c22))

## [0.4.0](https://github.com/theleagueof/fontship/compare/v0.3.4...v0.4.0) (2020-08-27)


### Features

* **rules:** Split makefile into init & actually processing ([0f43201](https://github.com/theleagueof/fontship/commit/0f4320191388096e387e19e2e488dbe173aacc84))
* **sfd:** Allow passing options or otherwise changing sfdnormalizer ([fd8a872](https://github.com/theleagueof/fontship/commit/fd8a872190c08d59ef9e2955e93edba1e20b36d2))
* **sfd:** Detect family names in FontForge sources ([8d3f645](https://github.com/theleagueof/fontship/commit/8d3f64534979471cc1e142e93daf72e188d70166))
* **ufo:** Add variable TTF output ([25cb71b](https://github.com/theleagueof/fontship/commit/25cb71bc64c780c98685fac0113e36fd7a45b4cb))
* **ufo:** Build interpolated instances from designspace ([2b8d41f](https://github.com/theleagueof/fontship/commit/2b8d41fdc07a298b472693abbe2312e33222f91d))
* **ufo:** Detect variable fonts via designspace file ([28247ce](https://github.com/theleagueof/fontship/commit/28247ce430f79d672a4ddf2af16feb80876a01a6))
* **ufo:** Hint VF builds using VTT hints if sources present ([8808bc6](https://github.com/theleagueof/fontship/commit/8808bc64245e95e746c0d8f34d2a36b0558a29fb))
* **ufo:** Iterate instances defined in designspace ([22b20bc](https://github.com/theleagueof/fontship/commit/22b20bc17d7c021e7d97c48c62ba45d7dab30c2b))


### Bug Fixes

* **designspace:** Disambiguate instances (statics) from masters (variables) ([1c178c6](https://github.com/theleagueof/fontship/commit/1c178c663a8ca054043b46d31c53237094b86018))
* **rules:** Move BUILDDIR variable to make default accessible to projects ([60b2f26](https://github.com/theleagueof/fontship/commit/60b2f26cad78d1435b5dcea7d16e514a3f8d7f71))
* **rules:** Use ‘,’ not ‘#’ as delimiter in sed expression ([#69](https://github.com/theleagueof/fontship/issues/69)) ([66f3aa3](https://github.com/theleagueof/fontship/commit/66f3aa335ecb76c6af60687187d53d8a74b9f7e5))
* **sfd:** Keep normalizer from touching sources unless we ask ([a46138e](https://github.com/theleagueof/fontship/commit/a46138ec4ffb71ca5e4edb9b35f2e18d82d80c7d))
* **ufo:** Catch multi-word instance names ([1d5d1ee](https://github.com/theleagueof/fontship/commit/1d5d1ee3c137f63b662b7187ce344e9a4a6b63f5))
* **ufo:** Detect base package-directory names ([f53bd43](https://github.com/theleagueof/fontship/commit/f53bd43900d382d18d84837d0245fa201955ea7b))
* **ufo:** Use configurable source directory ([13215d1](https://github.com/theleagueof/fontship/commit/13215d151c2fb8bf6e5646a88f735fe59acf12ac))

### [0.3.4](https://github.com/theleagueof/fontship/compare/v0.3.3...v0.3.4) (2020-08-22)


### Bug Fixes

* **build:** Correct typo in Github release workflow ([7fb84cb](https://github.com/theleagueof/fontship/commit/7fb84cb9de72c205d4add3e1b676b886c1cf8c75))
* **docker:** Add a way to deduce the repository name inside remote CI ([c563b1c](https://github.com/theleagueof/fontship/commit/c563b1cd31d50a43504014fd80a1e77c24ed1ac2))

### [0.3.3](https://github.com/theleagueof/fontship/compare/v0.3.2...v0.3.3) (2020-08-21)


### Bug Fixes

* **glyphs:** Deduce instance names from since source ([9eaff99](https://github.com/theleagueof/fontship/commit/9eaff99788526298ecd2473c27f4bf402c20254e))
* **glyphs:** Expand family names from from file names ([5c3a202](https://github.com/theleagueof/fontship/commit/5c3a20212afeac813df98bf97a96eaefeaf1cb91))
* **glyphs:** Fix usage of user-configurable source directory ([d61fadc](https://github.com/theleagueof/fontship/commit/d61fadccad03c114324ca567a56af2c7162b7d9e))
* **rules:** Correct syntax error blocking UFO/Glyphs canonical projects ([dab64e3](https://github.com/theleagueof/fontship/commit/dab64e3ea21225e96767b315de84ca3626cb111b))

### [0.3.2](https://github.com/theleagueof/fontship/compare/v0.3.1...v0.3.2) (2020-08-18)


### Features

* **docker:** Allow Docker in GH Actions usage with default arguments ([7133452](https://github.com/theleagueof/fontship/commit/713345205109aaa4eca51d09cb9fce246ee96d66))
* **otf:** Add CFF subroutinizer to processing chain ([978a88c](https://github.com/theleagueof/fontship/commit/978a88c5b5d6824994d59622771b44c413119f29))


### Bug Fixes

* **build:** Expect sanitized version string in version file ([ab25d46](https://github.com/theleagueof/fontship/commit/ab25d46f27df7ed5767293c4222120e6cb6ac6e2))

### [0.3.1](https://github.com/theleagueof/fontship/compare/v0.3.0...v0.3.1) (2020-08-17)


### Bug Fixes

* **docker:** Add missing dependency or sfdnormalize ([c296acf](https://github.com/theleagueof/fontship/commit/c296acf30e4e29faadbf75f9bb43d1b000213d49))
* **rules:** Keep last-commit file from being part of dependencies ([68742ae](https://github.com/theleagueof/fontship/commit/68742ae70cda0614911d3c5274b071a11d28d710))
* **sfd:** Keep normalizer from running except when changes present ([761a619](https://github.com/theleagueof/fontship/commit/761a61962be72f49cb4486abf1670d553dec8104))
* **tooling:** Work around bug in standard-version ([3f62f3a](https://github.com/theleagueof/fontship/commit/3f62f3a24dc288216b5fa06e14b6fd0ec9ae1ab1))

## [0.3.0](https://github.com/theleagueof/fontship/compare/v0.2.1...v0.3.0) (2020-08-17)


### Features

* **docker:** Distribute Dockerfile so people can build containers locally ([0033b9a](https://github.com/theleagueof/fontship/commit/0033b9a5a44d6b269f8909e0848b5da6f58c0f08))
* Add check target to confirm normalization ([628a633](https://github.com/theleagueof/fontship/commit/628a6333d62317c1fa935fe2511c9305c018f189))
* Add recipe to normalize SFD sources ([8ae2299](https://github.com/theleagueof/fontship/commit/8ae22990a2e3d2be0a392181a88a9e5c3551ed77))
* Allow multiple family-names per project ([b11fdca](https://github.com/theleagueof/fontship/commit/b11fdca9b4b33c1585f0db0d36b8054c747c65c3))
* Allow projects to toggle output formats ([00bde20](https://github.com/theleagueof/fontship/commit/00bde20d098508068fd6751c0dbd23d7d9306d64))
* Make source dir easily configurable and default to 'sources' ([819dc58](https://github.com/theleagueof/fontship/commit/819dc580f695690373bdd62a8b065a2ff5acaca9))
* Use templates to allow overriding how instances get built ([4e614b2](https://github.com/theleagueof/fontship/commit/4e614b216a8299aaa73901f1023d8f00ebda7642))


### Bug Fixes

* **build:** Use correct she-bang in bootstrap file ([a7d17c6](https://github.com/theleagueof/fontship/commit/a7d17c6eb219e0ab9ef9354421384dfde8fb4a7d))
* Change GPG key server so key fetch works in Docker ([fe53280](https://github.com/theleagueof/fontship/commit/fe5328001a5ab533d127f04ced12fe5efb9c941b))

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
