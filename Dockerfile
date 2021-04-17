#syntax=docker/dockerfile:1.2

ARG ARCHTAG

FROM docker.io/library/archlinux:base-$ARCHTAG AS base

# Monkey patch glibc to avoid issues with old kernels on hosts
RUN --mount=type=bind,target=/mp,source=build-aux/docker-glibc-workaround.sh /mp

# Setup Caleb’s hosted Arch repository with prebuilt dependencies
RUN pacman-key --init && pacman-key --populate
RUN sed -i  /etc/pacman.conf -e \
	'/^.community/{n;n;s!^!\n\[alerque\]\nServer = https://arch.alerque.com/$arch\n!}'
RUN echo 'keyserver pool.sks-keyservers.net' >> /etc/pacman.d/gnupg/gpg.conf
RUN pacman-key --recv-keys 63CC496475267693 && pacman-key --lsign-key 63CC496475267693

ARG RUNTIME_DEPS
ARG BUILD_DEPS

# Freshen all base system packages
RUN pacman --needed --noconfirm -Syuq && yes | pacman -Sccq

# Install run-time dependecies
RUN pacman --needed --noconfirm -Sq $RUNTIME_DEPS && yes | pacman -Sccq

# Setup separate image for build so we don’t bloat the final image
FROM base AS builder

# Install build time dependecies
RUN pacman --needed --noconfirm -Sq $BUILD_DEPS && yes | pacman -Sccq

# Set at build time, forces Docker’s layer caching to reset at this point
ARG VCS_REF=0

COPY ./ /src
WORKDIR /src

# GitHub Actions builder stopped providing git history :(
# See feature request at https://github.com/actions/runner/issues/767
RUN build-aux/bootstrap-docker.sh

RUN ./bootstrap.sh
RUN ./configure
RUN make
RUN make check
RUN make install DESTDIR=/pkgdir

# Work around BuiltKit / buildx bug, they can’t copy to symlinks only dirs
RUN mv /pkgdir/usr/local/{share/,}/man

FROM base AS final

LABEL maintainer="Caleb Maclennan <caleb@alerque.com>"
LABEL version="$VCS_REF"

COPY --from=builder /pkgdir /
RUN fontship --version

WORKDIR /data
ENTRYPOINT ["fontship"]
