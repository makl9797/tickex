#!/bin/sh

# tail -f /dev/null

npm install

npx hardhat compile

# npx hardhat node
npx hardhat node --fork https://rpc-mumbai.maticvigil.com

exec "$@"