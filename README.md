# ![Fontship Logo](https://raw.githubusercontent.com/theleagueof/fontship/master/media/logo.svg)

[![Rust Test Status](https://img.shields.io/github/workflow/status/theleagueof/fontship/Rust%20Test?label=Rust+Test&logo=Rust)](https://github.com/theleagueof/fontship/actions?workflow=Rust+Test)
[![Docker Build Status](https://img.shields.io/docker/cloud/build/theleagueof/fontship?label=Docker&logo=Docker)](https://hub.docker.com/repository/docker/theleagueof/fontship/builds)
[![Rust Lint Status](https://img.shields.io/github/workflow/status/theleagueof/fontship/Rust%20Lint?label=Rust+Lint&logo=Rust)](https://github.com/theleagueof/fontship/actions?workflow=Rust+Lint)
[![GitHub Workflow Status](https://img.shields.io/github/workflow/status/theleagueof/fontship/Superlinter?label=Linter&logo=Github)](https://github.com/theleagueof/fontship/actions?workflow=Superlinter)<br />
[![Latest Release](https://img.shields.io/github/v/release/theleagueof/fontship?label=Release&logo=dependabot)](https://github.com/theleagueof/fontship/releases/latest)
[![Chat on Gitter](https://img.shields.io/gitter/room/theleagueof/tooling?color=blue&label=Chat&logo=Gitter)](https://gitter.im/theleagueof/tooling?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)
[![Conventional Commits](https://img.shields.io/badge/Conventional%20Commits-1.0.0-blue.svg)](https://conventionalcommits.org)
[![Commitizen Friendly](https://img.shields.io/badge/Commitizen-friendly-blue.svg)](http://commitizen.github.io/cz-cli/)

## About Fontship

Fontship is a toolkit for generating fonts and tooling for a collaborative workflow.

Developed at [The League of Moveable Type](https://www.theleagueofmoveabletype.com/) with the needs of open-source font projects in mind, Fontship automates the process of turning your design sources into production ready font files and bundling them for publishing.
Yes you could take all the same steps manually.
Yes you could write your own scripts to get the same work done.
What Fontship brings to the table is a complete bundle of all the tooling you need to gather with most bits wired up already.

One building fonts from sources is completely automated, automatic builds from CI and publishing releases is just a small step away.
As an added bonus, everything is carefully organized to make asynchronous remote collaboration via version control systems (such as Git) as easy as possible.
Designers don’t even need to be using the same design tools!

Almost every aspect of the build steps and workflow can be tweaked on a per-project basis, but out of the box settings should work to build most font projects.

## Setup

Fontship can be used in any of three different ways:

1. Remotely via a CI runner that responds to events in a remote Git repository.
2. Locally via an all-inclusive Docker image for low hassle setup.
3. Locally via a regular system utility install (provided all the required dependencies are also installed).

*Note:* a fourth method supported through v0.5.0, direct inclusion of Fontship’s rule files into your project’s existing Makefile, has been deprecated.
Depending on your project, such usage may or may not continue to function with limitations for the time being, but new features added to the CLI will be *assumed* in the rules going forward.

### CI Setup

Build your fonts without installing or running anything locally!
Just push your sources to a remote Git repository and let Fontship do the rest.

For use with Github Actions, add a configuration file to your repository such as `.github/workflow/fontship.yml`:

```yaml
name: Fontship
on: [push, pull_request]
jobs:
  fontship:
    runs-on: ubuntu-latest
    name: Fontship
    steps:
      - name: Checkout
        uses: actions/checkout@v2
        with:
          fetch-depth: 0
      - name: Fetch tags
        run: git fetch --prune --tags
      - name: Fontship
        uses: theleagueof/fontship@latest
```

At the current time Fontship only builds the fonts into the current project directory, it doesn’t publish them anywhere.
You’ll need to post the resulting artifacts by (e.g. by attaching them to each CI run or publishing them on releases) as another step your project’s workflow. For a full working examples see [League Spartan’s](https://github.com/theleagueof/league-spartan/blob/master/.github/workflow/fontship.yml) or [Libertinus’s workflow](https://github.com/alerque/libertinus/blob/master/.github/workflow/fontship.yml)s.

Other CI runners could easily be supported, see [issue #32](https://github.com/theleagueof/fontship/issues/32) for details or to request sample configs for your favorite.

### Docker Setup

Prebuilt Docker images are available from [Docker Hub](https://hub.docker.com/repository/docker/theleagueof/fontship), [Github Packages](https://github.com/orgs/theleagueof/packages/container/package/fontship), or you can build them yourself.

The easiest way to instantiate a Docker container with all the right arguments is to set an alias (which can be added to your shell’s RC file to persist it):

Using Docker Hub as an example, an alias could be:

```console
$ alias fontship='docker run -it --volume "$(pwd):/data" --user "$(id -u):$(id -g)" theleagueof/fontship:latest'
```

Docker will automatically pull the containers it needs to run this the first time you use it, after which it will just use its local container cache.
To jump start the download without running `fontship` or to manually update your cache later (e.g. when *latest* gets updated to a new release) use `docker pull theleagueof/fontship:latest`.

You may substitute *latest* (which will always be the most recently released version tag) with *master* to use the freshest unreleased build, with a tag name such as *v0.3.2* to explicitly use a specific version, or with *HEAD* to use an image built locally.

To build a docker image locally, you’ll want to clone this repository and run `./bootstrap.sh` or download and extract the sources from a release, then run:

```console
$ ./configure
$ make docker
```

### System Setup

If you use Arch Linux, you can install [this AUR package](https://aur.archlinux.org/packages/fontship) (prebuilt in [this repostiory](https://wiki.archlinux.org/index.php/Unofficial_user_repositories#alerque)).

Otherwise to install and use locally from source, you’ll need some dependencies:

* Git,
* GNU core utilities plus `diffutils`, `bsdtar`, `entr`, `zsh`,
* GNU `make` (4.2+) with corresponding autoconf tools,
* Python 3 plus assorted modules, see *requirements.txt* file,
* Rust tools including `cargo` and `rustc` to build the CLI,
* And a handfull of other font related CLI utilities, namely: `sfn2woff-zopfli`, `psautohint`, `ttfautohint`, and `woff2_compress`.

To install the software to your computer, either clone this repository and run `./bootstrap.sh` or [download and extract the latest release](https://github.com/theleagueof/fontship/releases), then run:

```sh
$ ./configure
$ make
$ sudo make install
```

## Usage

### Building

To build all the possible formats for your font project, run

```console
$ fontship make all
```

To only generate a specific format, try:

```console
# Just static OTF fonts
$ fontship make otf

# All static formats
$ fontship make static

# All variable formats
$ fontship make variable

# Just variable TTF format
$ fontship make variable-ttf
```

If you’re only interested in one specific file (say, a static weight instance) you can specify the exact file name you expect to get the fastest possible rebuild of just that file:

```console
$ fontship make FooBar-Black.otf
```

### Publishing

When everything is ready or you want to actually ship a font (or send a sample to a friend), you’ll want to build the distribution package:

```console
$ fontship make dist
```

### Versioning

The font version setting in all generated fonts is determined by the tag on the git repository.
Version tags should conform to the `MAJOR.MINOR` format descriped by [openfv](https://github.com/openfv/openfv#3-version-number-semantics).
