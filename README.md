# Liquidsoap
Liquidsoap for Docker

[![Docker Pulls](https://img.shields.io/docker/pulls/phasecorex/liquidsoap)](https://hub.docker.com/r/phasecorex/liquidsoap)
[![Build Status](https://github.com/PhasecoreX/docker-liquidsoap/workflows/build/badge.svg)](https://github.com/PhasecoreX/docker-liquidsoap/actions?query=workflow%3Abuild)
[![BuyMeACoffee](https://img.shields.io/badge/buy%20me%20a%20coffee-donate-orange)](https://buymeacoff.ee/phasecorex)
[![PayPal](https://img.shields.io/badge/paypal-donate-blue)](https://paypal.me/pcx)

Assuming you have a folder `/music` with a liquidsoap script file in it:
```
docker run --link some-icecast -v /music:/music:ro phasecorex/liquidsoap /music/script.liq
```
This has been heavily modified from infiniteproject/liquidsoap:
- Added support for opus, flac, and m4a/aac files
- Much smaller image size (203MB instead of 1.66GB)
- Multiarch support
    - You can run it on a Raspberry Pi if you want to.
- Runs as non-root user
	- You can set environment variable `PUID` to whatever user ID you want Liquidsoap to run as. Defaults to 1000.
	- You can also set `PGID` to a group ID you want Liquidsoap to run as. If you don't, it defaults to whatever the UID is set to.
- Timezone support
	- You can set environment variable `TZ` to a timezone (e.g. `TZ=America/Detroit`) so that Liquidsoap logs are in your timezone.
- Niceness support
    - You can set environment variable `NICENESS` to a value from -20 to 19 to set the niceness of the Liquidsoap process.

Feedback appreciated!
