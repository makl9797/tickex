#!/bin/sh
ls
cd /opt/app
mix deps.get
mix ecto.migrate
mix phx.server

exec "$@"