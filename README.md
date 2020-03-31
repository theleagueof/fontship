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

Install the software to your computer. Either clone this repository and
run `autoreconf --install` or download and extract a tarball, then run:

    $ ./configure
    $ make
    $ sudo make install

### Docker Setup

Add an alias:

    $ alias fontship='docker run -it --volume "$(pwd):/data" --user "$(id -u):$(id -g)" theleagueof/fontship:master"

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
