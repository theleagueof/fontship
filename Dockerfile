FROM docker.io/library/archlinux:base-20210131.0.14634 AS base

# Setup Caleb’s hosted Arch repository with prebuilt dependencies
RUN pacman-key --init && pacman-key --populate
RUN sed -i  /etc/pacman.conf -e \
	'/^.community/{n;n;s!^!\n\[alerque\]\nServer = https://arch.alerque.com/$arch\n!}'
RUN echo 'keyserver pool.sks-keyservers.net' >> /etc/pacman.d/gnupg/gpg.conf
RUN pacman-key --recv-keys 63CC496475267693 && pacman-key --lsign-key 63CC496475267693

# This is a hack to convince Docker Hub that its cache is behind the times.
# This happens when the contents of our dependencies changes but the base
# system hasn’t been refreshed. It’s helpful to have this as a separate layer
# because it saves a lot of time for local builds, but it does periodically
# need a poke. Incrementing this when changing dependencies or just when the
# remote Docker Hub builds die should be enough.
ARG DOCKER_HUB_CACHE=0

# Freshen all base system packages
RUN pacman --needed --noconfirm -Syuq && yes | pacman -Sccq

# Install run-time dependecies (increment cache var above)
RUN pacman --needed --noconfirm -Syq \
		diffutils entr font-v gftools git libarchive libgit2 make psautohint python sfd2ufo sfdnormalize sfnt2woff-zopfli ttfautohint woff2 zsh \
		python-{babelfont,brotli,cffsubr,defcon,font{make,tools},fs,lxml,pcpp,skia-pathops,ufo{2ft-git,lib2,normalizer},unicodedata2,zopfli,vttlib} \
	&& yes | pacman -Sccq

# Setup separate image for build so we don’t bloat the final image
FROM base AS builder

# Install build time dependecies
RUN pacman --needed --noconfirm -Syq \
		base-devel cargo jq rust \
	&& yes | pacman -Sccq

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

FROM base AS final

LABEL maintainer="Caleb Maclennan <caleb@alerque.com>"
LABEL version="$VCS_REF"

COPY --from=builder /pkgdir /
RUN fontship --version

WORKDIR /data
ENTRYPOINT ["fontship"]
