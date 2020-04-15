# fontship

[![Gitter](https://badges.gitter.im/theleagueof/tooling.svg)](https://gitter.im/theleagueof/tooling?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge)

A font development toolkit and collaborative work flow developed by [The
League of Moveable Type](https://www.theleagueofmoveabletype.com/).

## Setup & Usage

Fontship can be used in any of three different ways:

1.  Directly on a local system that has all the required dependencies.
2.  On a local system via a Docker image for low hastle setup.
3.  Remotely via a CI runner.

### Local Setup

To install and use locally, you'll need some dependencies:

* Git
* Python 3
* GNU Make 4.2 & automake
* GNU core utilities (tar, touch, sed, etc.)
* BSD tar
* Assorted python modules see `requirements.txt`.

Install the software to your computer. Either clone this repository and
run `./bootstrap.sh` or download and extract a tarball, then run:

    $ ./configure
    $ make
    $ sudo make install

### Docker Setup

Docker images are available from Docker Hub or you can build them yourself.

Add an alias:

    $ alias fontship='docker run -it --volume "$(pwd):/data" --user "$(id -u):$(id -g)" theleagueof/fontship:latest fontship"

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
