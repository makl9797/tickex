FROM oven/bun:1.0.20-slim as base

WORKDIR /chain

RUN apt-get update && \
    apt-get install --no-install-recommends -y \
        build-essential && \
    rm -fr /var/lib/apt/lists/* && \
    rm -rf /etc/apt/sources.list.d/*

# RUN bun install --save-dev hardhat
# RUN bun install --save-dev ganache-cli

# COPY package.json /chain
# COPY bun.lockb /chain

# RUN bun install

COPY ./entrypoint.sh .

RUN ["chmod", "+x", "entrypoint.sh"]

ENTRYPOINT ["./entrypoint.sh"]