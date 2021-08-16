FROM ocaml/opam:debian-10 as builder

ENV PACKAGES="taglib mad.0.4.5 lame vorbis.0.7.1 cry samplerate.0.1.5 opus.0.1.3 fdkaac faad.0.4.0 ffmpeg.0.4.3 gstreamer lo.0.1.2 liquidsoap.1.4.4"

RUN set -eux; \
    sudo sed -i 's/$/ non-free/' /etc/apt/sources.list; \
    sudo apt-get update; \
    for package in $PACKAGES; do \
        opam depext --install $package; \
    done




RUN set -eux; \
    eval $(opam env); \
    mkdir -p /home/opam/root/app; \
    mv $(command -v liquidsoap) /home/opam/root/app; \
    opam depext --list $PACKAGES > /home/opam/root/app/depexts; \
    mkdir -p /home/opam/root/$OPAM_SWITCH_PREFIX/lib; \
    mv $OPAM_SWITCH_PREFIX/share /home/opam/root/$OPAM_SWITCH_PREFIX; \
    mv $OPAM_SWITCH_PREFIX/lib/liquidsoap /home/opam/root/$OPAM_SWITCH_PREFIX/lib



FROM phasecorex/user-debian:10-slim

COPY --from=builder /home/opam/root /

RUN set -eux; \
    sed -i 's/$/ non-free/' /etc/apt/sources.list; \
    apt-get update; \
    cat /app/depexts | xargs apt-get install -y --no-install-recommends; \
    apt-get install -y --no-install-recommends gstreamer1.0-tools gstreamer1.0-libav gstreamer1.0-plugins-base gstreamer1.0-plugins-good gstreamer1.0-plugins-bad gstreamer1.0-plugins-ugly; \
    rm -rf /var/lib/apt/lists/*; \
    /app/liquidsoap --version

COPY --from=hairyhenderson/gomplate:alpine /bin/gomplate /bin/gomplate
RUN touch /config.liq; \
    chmod 666 /config.liq


COPY entrypoint.sh /entrypoint.sh
COPY config.liq /config.liq.base
EXPOSE 7777/tcp
ENTRYPOINT ["user-entrypoint", "/entrypoint.sh"]
