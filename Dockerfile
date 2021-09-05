FROM phasecorex/user-debian:10-slim

COPY --from=registry.gitlab.com/ondabeta/ob-liquidsoap:builder /home/opam/root /

RUN set -eux; \
    sed -i 's/$/ non-free/' /etc/apt/sources.list; \
    apt-get update; \
    cat /app/depexts | xargs apt-get install -y --no-install-recommends; \
    apt-get install -y --no-install-recommends gstreamer1.0-tools gstreamer1.0-libav gstreamer1.0-plugins-base gstreamer1.0-pulseaudio gstreamer1.0-plugins-good gstreamer1.0-plugins-bad gstreamer1.0-plugins-ugly; \
    rm -rf /var/lib/apt/lists/*; \
    /app/liquidsoap --version

COPY --from=hairyhenderson/gomplate:alpine /bin/gomplate /bin/gomplate
RUN touch /config.liq; \
    chmod 666 /config.liq


COPY entrypoint.sh /entrypoint.sh
COPY config.liq /config.liq.base
COPY pulse-client.conf /etc/pulse/client.conf
EXPOSE 7777/tcp
ENTRYPOINT ["user-entrypoint", "/entrypoint.sh"]
