#!/bin/sh

# tail -f /dev/null

npm install

npx hardhat node

exec "$@"