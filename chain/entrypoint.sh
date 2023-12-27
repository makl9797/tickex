#!/bin/sh

tail -f /dev/null

bun install

exec "$@"