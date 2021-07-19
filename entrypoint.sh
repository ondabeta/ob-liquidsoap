#!/bin/bash

cat /config.liq.base | gomplate > /config.liq
 
exec "/app/liquidsoap" "/config.liq"
