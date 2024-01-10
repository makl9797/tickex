#!/bin/sh

cd assets
npm install
cd ..
mix deps.get
mix ecto.migrate
mix assets.deploy
mix phx.server

exec "$@"