#!/bin/sh
set -e
nginx -t
exec nginx -g 'daemon off;'
