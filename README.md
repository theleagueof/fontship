# Fontship

[![Docker Build Status](https://img.shields.io/docker/cloud/build/theleagueof/fontship?label=Docker%20Build&logo=Docker)](https://hub.docker.com/repository/docker/theleagueof/fontship/builds)
[![Chat on Gitter](https://img.shields.io/gitter/room/theleagueof/tooling?color=blue&label=Chat&logo=Gitter)](https://gitter.im/theleagueof/tooling?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

A font development toolkit and collaborative work flow developed by [The
League of Moveable Type](https://www.theleagueofmoveabletype.com/).

## Setup & Usage

Fontship can be used in any of four different ways:

1.  Directly on a local system that has all the required dependencies and fontship has been installed.
2.  On a local system via a Docker image for low hastle setup.
3.  Remotely via a CI runner.
4.  By including fontship into your project's Makefile.

### Local Setup

To install and use locally, you'll need some dependencies:

* Git
* GNU core utilities plus `bsdtar`, `entr`, `zsh`
* GNU `make` (4.2+) with corresponding autoconf tools
* Python 3 plus assorted modules, see *requirements.txt* file

Install the software to your computer. Either clone this repository and
run `./bootstrap.sh` or download and extract a tarball, then run:

    $ ./configure
    $ make
    $ sudo make install

### Docker Setup

Docker images are available from Docker Hub or you can build them yourself.

Add an alias:

    $ alias fontship='docker run -it --volume "$(pwd):/data" --user "$(id -u):$(id -g)" theleagueof/fontship:latest"

You may substitute *latest*, which will always be the most recently released tagged version, with *master* to use the latest unreleased build, with a tag name to explicitly use a specific version, or with *HEAD* to use an image build locally.

To build a docker image locally, you'll want to clone this repository and run `./bootstrap.sh` or download and extract a tarball, then run:

    $ ./configure
    $ make docker

### CI Setup

Add a Github Actions configuration file to your repository such as
`.github/workflow/fontship.yml`:

``` yaml
name: Fontship
on: [push, pull_request]
jobs:
  fontship:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@master
      - name: Fontship
        uses: theleagueof/fontship@master
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

### Makefile Setup

If ⓐ your system has all the dependencies and ⓑ your project already has a `Makefile`, you can extend your existing makefile with fontship's targets my including it:

```makefile
include path/to/fontship/src/Makefile
```

This may reference a path to fontship as a git submodule (useful for locking the fontship version to your project's build), or just a relative path to somewhere you have the fontship source.
