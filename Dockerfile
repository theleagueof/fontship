FROM archlinux:20200306 AS fontship-base

RUN sed -i -e '/IgnorePkg *=/s/^.*$/IgnorePkg = coreutils/' /etc/pacman.conf
# Setup Caleb's hosted Arch repository with prebuilt dependencies
RUN pacman-key --init && pacman-key --populate
RUN sed -i  /etc/pacman.conf -e \
	'/^.community/{n;n;s!^!\n\[alerque\]\nServer = https://arch.alerque.com/$arch\n!}'
RUN pacman-key --recv-keys 63CC496475267693 && pacman-key --lsign-key 63CC496475267693

# Freshen all base system packages
RUN pacman --needed --noconfirm -Syuq && yes | pacman -Sccq

# Install fontship run-time dependecies
RUN pacman --needed --noconfirm -Syq \
		entr font-v gftools git libarchive make psautohint python sfd2ufo sfnt2woff-zopfli ttfautohint woff2 zsh \
		python-{babelfont,brotli,click,defcon,font{make,tools},fs,lxml,pcpp,pygit2,skia-pathops,ufo{2ft,lib2,normalizer},unicodedata2,zopfli} \
	&& yes | pacman -Sccq

# Setup separate image to build fontship so we don't bloat the final image
FROM fontship-base AS fontship-builder

# Install build time dependecies
RUN pacman --needed --noconfirm -Syq base-devel && yes | pacman -Sccq

# Set at build time, forces Docker's layer caching to reset at this point
ARG VCS_REF=0

COPY ./ /src
WORKDIR /src

RUN git clean -dxf ||:
RUN git fetch --unshallow ||:
RUN git fetch --tags ||:

RUN ./bootstrap.sh
RUN ./configure
RUN make
RUN make install DESTDIR=/pkgdir

FROM fontship-base AS fontship

LABEL maintainer="Caleb Maclennan <caleb@alerque.com>"
LABEL version="$VCS_REF"

COPY --from=fontship-builder /pkgdir /

WORKDIR /data
ENTRYPOINT ["fontship"]
