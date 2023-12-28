#!/bin/sh

mix deps.get
mix ecto.migrate
mix phx.server

exec "$@"