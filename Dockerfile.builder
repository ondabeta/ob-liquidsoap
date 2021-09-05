FROM ocaml/opam:debian-10

ENV PACKAGES="ogg.0.5.2 taglib mad.0.4.5 lame vorbis.0.7.1 cry samplerate.0.1.5 opus.0.1.3 fdkaac faad.0.4.0 ffmpeg.0.4.3 pulseaudio gstreamer lo.0.1.2 liquidsoap.1.4.4"



RUN set -eux; \
    sudo sed -i 's/$/ non-free/' /etc/apt/sources.list; \
    sudo apt-get update; \
    sudo apt-get install --no-install-recommends -qq -yy debianutils libavcodec-dev libavdevice-dev libavformat-dev libavutil-dev libfaad-dev libfdk-aac-dev libgstreamer-plugins-base1.0-dev libgstreamer1.0-dev liblo-dev libmad0-dev libmp3lame-dev libogg-dev libopus-dev libpcre3-dev libpulse-dev libsamplerate-dev libswresample-dev libswscale-dev libtag1-dev libvorbis-dev pkg-config 
 # for package in $PACKAGES; do \
RUN set -eux; \
    opam depext --install $PACKAGES;
    # done




RUN set -eux; \
    eval $(opam env); \
    mkdir -p /home/opam/root/app; \
    mv $(command -v liquidsoap) /home/opam/root/app; \
    opam depext --list $PACKAGES > /home/opam/root/app/depexts; \
    mkdir -p /home/opam/root/$OPAM_SWITCH_PREFIX/lib; \
    mv $OPAM_SWITCH_PREFIX/share /home/opam/root/$OPAM_SWITCH_PREFIX; \
    mv $OPAM_SWITCH_PREFIX/lib/liquidsoap /home/opam/root/$OPAM_SWITCH_PREFIX/lib

