# Changelog

All notable changes to this project will be documented in this file. See [commit-and-tag-version](https://github.com/absolute-version/commit-and-tag-version) for commit guidelines.

## [0.10.1](https://github.com/theleagueof/fontship/compare/v0.10.0...v0.10.1) (2025-01-25)


### New Features

* **deps:** Update git2 crate to enable build against libgit2-1.9 ([a42e03a](https://github.com/theleagueof/fontship/commit/a42e03a478bdced8cb39719830f48748e02cb7a0))


### Bug Fixes

* **build:** Set correct final permissions on intermediary shell completion artifacts ([7cee491](https://github.com/theleagueof/fontship/commit/7cee4915b5950da0e1e8cd39db20d3156978108c))
* **gha:** Stop forcing all GH Action runs to install-dist ([319c56f](https://github.com/theleagueof/fontship/commit/319c56f942d796aa4c52bc6359e7e48bd1bdb3f9))

## [0.10.0](https://github.com/theleagueof/fontship/compare/v0.9.6...v0.10.0) (2024-09-23)


### ⚠ BREAKING CHANGES

* Everything is relicensed. All previous contributors
signed off ages ago so old code can now be used under either terms and
future contributions will be only under the GPL.

### New Features

* **rules:** Make output compression more easily configurable ([72c5ea7](https://github.com/theleagueof/fontship/commit/72c5ea7222e2a63de72362781fb20d65b24e2f88))


### Bug Fixes

* **action:** Args passed to Docker must be an array even if all you want is a string ([a1cabd2](https://github.com/theleagueof/fontship/commit/a1cabd2c92b0147ab6e9ea732d7a9a377b148c7f))


### Behind the Scenes

* Relicense AGPL → GPL ([f098f20](https://github.com/theleagueof/fontship/commit/f098f209a041f7a1b7759f333baa49e2a8931488)), closes [#35](https://github.com/theleagueof/fontship/issues/35)

## [0.9.6](https://github.com/theleagueof/fontship/compare/v0.9.5...v0.9.6) (2024-09-20)


### New Features

* **actions:** Make it easier to override input arguments from workflows ([8150a90](https://github.com/theleagueof/fontship/commit/8150a90db09c9f78d707b75354947ee404f25206))
* **rules:** Output detected family names to GitHub Actions ([73cc0c6](https://github.com/theleagueof/fontship/commit/73cc0c6877dabc590352d69bf5a1789e5cf0c201))


### Bug Fixes

* **rules:** Update method of passing GitHub CI variables to current API ([fe277e4](https://github.com/theleagueof/fontship/commit/fe277e4ca72edc59a06c99e653bd52b60c0979f3))

## [0.9.5](https://github.com/theleagueof/fontship/compare/v0.9.4...v0.9.5) (2024-09-19)


### Bug Fixes

* **docker:** Rebuild Docker images with updated gftools dependencies ([c41be73](https://github.com/theleagueof/fontship/commit/c41be731ffbafe3952ff6bfa3ff3433073ffabd5))

## [0.9.4](https://github.com/theleagueof/fontship/compare/v0.9.3...v0.9.4) (2024-09-19)


### Bug Fixes

* **docker:** Supply stat to Docker entry point for UID detection ([30377dc](https://github.com/theleagueof/fontship/commit/30377dcb3bde30c936228f79ace51e1899b57c09))

## [0.9.3](https://github.com/theleagueof/fontship/compare/v0.9.2...v0.9.3) (2024-09-19)


### Bug Fixes

* **build:** Inform autotools of the new location for packaged shell scripts ([0d15eb8](https://github.com/theleagueof/fontship/commit/0d15eb8b4f32363d8f197be238abf3800246a6f8))

## [0.9.2](https://github.com/theleagueof/fontship/compare/v0.9.1...v0.9.2) (2024-09-17)

## [0.9.1](https://github.com/theleagueof/fontship/compare/v0.9.0...v0.9.1) (2024-09-16)


### Bug Fixes

* **build:** Package all source files in distribution tarball ([38b93e9](https://github.com/theleagueof/fontship/commit/38b93e9aebcc0001a64fa3d6561806aeb934091e))

## [0.9.0](https://github.com/theleagueof/fontship/compare/v0.8.2...v0.9.0) (2024-09-16)


### New Features

* **cli:** Overhaul UI, friendlier to both CI/scripts and interactive use ([517a46b](https://github.com/theleagueof/fontship/commit/517a46b73635785250369886aa16c2fbbb53fe16))
* **rules:** Allow extension of rules *after* Fontship loads ([b7df1fd](https://github.com/theleagueof/fontship/commit/b7df1fd9030841e487d00e3cd24abc02c5fe8030))


### Bug Fixes

* **build:** Avoid the perceived need for an extra automake cycle in dist tarball ([7b72816](https://github.com/theleagueof/fontship/commit/7b7281640c8feb2ba204d381d27f1ba4cebc93bb))
* **build:** Swap unportable ‘cp -bf’ for ‘install’ ([41ed637](https://github.com/theleagueof/fontship/commit/41ed637ade5e8dc55759e4113d75cdc76ae6e2c3))
* **cli:** Avoid Unicode direction isolation marks in CLI output ([bbae252](https://github.com/theleagueof/fontship/commit/bbae2527a22518c780f922c07baa77f8689618eb))
* **rules:** Use python protobuf, our protoc is too new for gftools ([fc0e4f2](https://github.com/theleagueof/fontship/commit/fc0e4f29b74aa2d90508b60f2a4f5b7a3584dd48))

### [0.8.2](https://github.com/theleagueof/fontship/compare/v0.8.1...v0.8.2) (2021-05-14)


### Bug Fixes

* **build:** Replace all spaces in font family when deriving project id ([da4fa72](https://github.com/theleagueof/fontship/commit/da4fa720948a733a1a76975095b35b5195f83b56))

### [0.8.1](https://github.com/theleagueof/fontship/compare/v0.8.0...v0.8.1) (2021-05-14)


### Features

* **actions:** Run GitHub Action workflows with prebuilt containers ([3dd5443](https://github.com/theleagueof/fontship/commit/3dd544362700507ac3adb60658f2c1bcaf25825f))

## [0.8.0](https://github.com/theleagueof/fontship/compare/v0.7.6...v0.8.0) (2021-04-17)


### Features

* **cli:** Add check to *not* run from Fontship source tree ([2812ead](https://github.com/theleagueof/fontship/commit/2812ead765a198d3d5962d1a056ef0535c1f246a))
* **cli:** Reset file modification timestamps on setup ([f3785fd](https://github.com/theleagueof/fontship/commit/f3785fd641059bbd8a0f885cb1dbbfb1fc388080))
* **docker:** Publish images to GHCR ([9f0d551](https://github.com/theleagueof/fontship/commit/9f0d5516294f96891b704d23135198aa798c30b6))
* **sfd:** Automatically glean intstance names from sources ([4afa1bc](https://github.com/theleagueof/fontship/commit/4afa1bcc6eb61508d5692665bf17f38901bde2ed))
* **sfd:** Include a default (sfd2ufo) way to build FontForge projects ([d5ab565](https://github.com/theleagueof/fontship/commit/d5ab56572ae97b8352253f91ad43e725cd222ae4))


### Bug Fixes

* **build:** Correct detection of completions dir on systems with pkg-config ([b33a11e](https://github.com/theleagueof/fontship/commit/b33a11e5c7015f3b6386e41e5fe12dd27f2e0337))
* **build:** Correct dist vs. nodist source lists ([a9238cb](https://github.com/theleagueof/fontship/commit/a9238cbaae63a530e1c51d8b0df55dbae78c9386))
* **build:** Handle version file for out-of-source builds ([b874172](https://github.com/theleagueof/fontship/commit/b874172235a8d050d69fb66f484a257ec79f8ef3))
* **deps:** Update Python APIs used to fetch meta data ([08c263b](https://github.com/theleagueof/fontship/commit/08c263b86aa5426bc556dd5c602ff6f94897ef3f))
* **docker:** Switch to BuildKit and make Docker Hub cooperate ([6e770e8](https://github.com/theleagueof/fontship/commit/6e770e821e765612403138aa0f16137612c0e153))
* **docker:** Work around archaic host kernels on Docker Hub ([f3cf345](https://github.com/theleagueof/fontship/commit/f3cf345c217446f7bb7fa68b6cfb5889c8b78a46))

### [0.7.6](https://github.com/theleagueof/fontship/compare/v0.7.5...v0.7.6) (2021-01-31)


### Features

* **build:** Detect system dependencies and allow substitution at build time ([f61fb30](https://github.com/theleagueof/fontship/commit/f61fb307e4034d9dd3ac565d81417f6e5028455b))
* **build:** Finish up renameable build support ([b304140](https://github.com/theleagueof/fontship/commit/b3041401df642f7d3941ca30bb2ef3904ceabed5))
* **cli:** Detect fontship.mk file as project specific rules ([b03d563](https://github.com/theleagueof/fontship/commit/b03d563597c64bd93e0ac4420ba587e67dac1d2a))
* **docker:** Extend renameable build support to Docker ([c59d0ff](https://github.com/theleagueof/fontship/commit/c59d0ff63e614e8628c64460c743d06b47539808))


### Bug Fixes

* **cli:** Avoid tripping up on filnames with brackets ([5b464e1](https://github.com/theleagueof/fontship/commit/5b464e157f1606fac455c786138e59e1134ae55c))

### [0.7.5](https://github.com/theleagueof/fontship/compare/v0.7.4...v0.7.5) (2021-01-09)


### Bug Fixes

* **rules:** Exclude excess version info from tagged dist packaging ([c1beed7](https://github.com/theleagueof/fontship/commit/c1beed7865bb7db05d39bde6afc7155903a9e7f4))

### [0.7.4](https://github.com/theleagueof/fontship/compare/v0.7.3...v0.7.4) (2021-01-09)


### Bug Fixes

* **build:** Distribute aux script used in configure ([8149664](https://github.com/theleagueof/fontship/commit/81496640d792aa76a288c9c62527cddfd114666e))
* **build:** Run autoupdate to fix autoconf syntax issue ([d87441a](https://github.com/theleagueof/fontship/commit/d87441a3f7deaa712b0a108aac2b40037bac7da0))

### [0.7.3](https://github.com/theleagueof/fontship/compare/v0.7.2...v0.7.3) (2021-01-09)


### Bug Fixes

* **docker:** Force update to catch gftools package rebuild ([46eba88](https://github.com/theleagueof/fontship/commit/46eba88dddcf05ef4e01173c0898cc6fe8a8f471))

### [0.7.2](https://github.com/theleagueof/fontship/compare/v0.7.1...v0.7.2) (2020-12-18)


### Features

* **cli:** Pass through output of special debug target ([0f6471f](https://github.com/theleagueof/fontship/commit/0f6471f0a3f4a660dfc0492d491bd90734761f43))


### Bug Fixes

* **cli:** Detect project name from local Git repo too ([b7c3197](https://github.com/theleagueof/fontship/commit/b7c3197e4e31690de6614b5bbe021e45efde5136))
* **cli:** Disallow quiet flag if debug or verbose enabled ([97a3a49](https://github.com/theleagueof/fontship/commit/97a3a49daf274cca275cd88aa25bbc35b9ba6df6))
* **ufo:** Use best available family name, not legacy ([368201e](https://github.com/theleagueof/fontship/commit/368201e2a78454a9d183d5c47762c750a38a550d))


### Performance Improvements

* **rules:** Stop iteratively reading every value on every use ([01eea8d](https://github.com/theleagueof/fontship/commit/01eea8d0a3348106d3eeca94b363a1ebb07bb863))

### [0.7.1](https://github.com/theleagueof/fontship/compare/v0.7.0...v0.7.1) (2020-11-18)


### Bug Fixes

* **actions:** Repair detection of project name in GitHub Actions ([bc859de](https://github.com/theleagueof/fontship/commit/bc859dec4a70c79d0e13573da0762661cc351af4))

## [0.7.0](https://github.com/theleagueof/fontship/compare/v0.6.2...v0.7.0) (2020-11-17)


### ⚠ BREAKING CHANGES

* **rules:** Complete deprecation of using rules without CLI

### Features

* **cli:** Add setup operation to normalize SHA lengths ([4945f53](https://github.com/theleagueof/fontship/commit/4945f534cdece4ed504af5570b5f0ad8dbb500f8))
* **cli:** Rebuild .gitignore on setup ([527a0ed](https://github.com/theleagueof/fontship/commit/527a0eddb8ca97596b90f14b899db781b41bf811))
* **rules:** Add .gitignore file builder ([57c0925](https://github.com/theleagueof/fontship/commit/57c092521641924f136c0006880e733f07c0e009))


### Bug Fixes

* **ufo:** Bring variable UFO sources inline with Glyphs ([1680e29](https://github.com/theleagueof/fontship/commit/1680e29553cbc0a6e9cf82831788c044e4623ca3))


### Miscellaneous Chores

* **rules:** Complete deprecation of using rules without CLI ([e138edf](https://github.com/theleagueof/fontship/commit/e138edffce1357665121d8a32ef1a781cfdb8cbf))

### [0.6.2](https://github.com/theleagueof/fontship/compare/v0.6.1...v0.6.2) (2020-10-29)


### Bug Fixes

* **actions:** Don't capture strings read by GHA ([27a8494](https://github.com/theleagueof/fontship/commit/27a8494ab0c12f4de1f51fadcd6860b326466f6f))
* **cli:** Don’t use backticks to unbreak zsh compdef ([#108](https://github.com/theleagueof/fontship/issues/108)) ([50c9a53](https://github.com/theleagueof/fontship/commit/50c9a537ee96d4028a4dd7da39f86af4bd459ab2))
* **cli:** Return error code if make itself dies ([7197ac5](https://github.com/theleagueof/fontship/commit/7197ac5fb692487a9be406d8b57f11df9dc399f1))

### [0.6.1](https://github.com/theleagueof/fontship/compare/v0.6.0...v0.6.1) (2020-10-26)


### Bug Fixes

* **build:** Configure release script to bump lock file to match releases ([71f1a77](https://github.com/theleagueof/fontship/commit/71f1a77a88f10a88bb15479c75c8f2545656be04))

## [0.6.0](https://github.com/theleagueof/fontship/compare/v0.5.0...v0.6.0) (2020-10-26)


### ⚠ BREAKING CHANGES

* **cli:** Deprecate direct inclusion of rule files (non-CLI based usage)

### Features

* **build:** Allow name transformations during build ([0fc24d6](https://github.com/theleagueof/fontship/commit/0fc24d6ec05b20dfc918fbfd375cca7b98e7197f))
* **build:** Package CLI built from Rust instead of Python sources ([58ce700](https://github.com/theleagueof/fontship/commit/58ce7008021b54f6d9fa41450184f42fd673ffee))
* **cli:** Capture STDOUT/STDERR from make subprocess ([07c4e0e](https://github.com/theleagueof/fontship/commit/07c4e0edcdc0e41c3802db1624f9e3441060c23a))
* **cli:** Deprecate direct inclusion of rule files (non-CLI based usage) ([7dfd6c1](https://github.com/theleagueof/fontship/commit/7dfd6c1328edcc530ad72fa8afdee5be3ffcc12f))
* **cli:** Generate shell completion routines ([#101](https://github.com/theleagueof/fontship/issues/101)) ([3ce84dd](https://github.com/theleagueof/fontship/commit/3ce84dd56831f66bc8303e67aa6a02017646685d))
* **rules:** Wrap make targets in shell scripts with hooks ([9989776](https://github.com/theleagueof/fontship/commit/998977682184b54c4945e1cdad7576f2364bccd4))


### Bug Fixes

* **actions:** Manage GH Actions builds where no version info available ([a74480d](https://github.com/theleagueof/fontship/commit/a74480d44d96e4dabf0c11beeaa29a3b2c340e48))
* **build:** Add used but undefined error function ([cc48078](https://github.com/theleagueof/fontship/commit/cc480783eb691daa1626c562801094889c1ac106))
* **rules:** Account for locating projects that don't have local rules ([12ce56c](https://github.com/theleagueof/fontship/commit/12ce56c30f2a974ad47d2aebba259295534b1f12))
* **rules:** Remove the same TMP file we create, not a different one ([#92](https://github.com/theleagueof/fontship/issues/92)) ([a01fba3](https://github.com/theleagueof/fontship/commit/a01fba3ad0619588af6d64d412fd7e0c28b07b5a))
* **rules:** Use more robust value quoting/escaping method ([85c7061](https://github.com/theleagueof/fontship/commit/85c7061dae9c2f8c464da2b1be98017a1f12e072))

## [0.5.0](https://github.com/theleagueof/fontship/compare/v0.4.3...v0.5.0) (2020-10-08)


### Features

* **woff:** Generate webfonts from OTF if possible, fallback to TTF ([#85](https://github.com/theleagueof/fontship/issues/85)) ([dfcc300](https://github.com/theleagueof/fontship/commit/dfcc3000c965a90c8ed1bb31dabe13928de3512b))
* Add logo svg files ([cc9a213](https://github.com/theleagueof/fontship/commit/cc9a2139e0a43a289e0b9712af405a550d1f3b11))
* Add source logo vector file ([62d4e9f](https://github.com/theleagueof/fontship/commit/62d4e9f4222f09ad023e8779d14d2a0bfb537cb5))

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
