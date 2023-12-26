FROM oven/bun:1.0.20-slim as base

WORKDIR /chain

RUN apt-get update && \
    apt-get install --no-install-recommends -y \
        build-essential \
        python3 && \
    rm -fr /var/lib/apt/lists/* && \
    rm -rf /etc/apt/sources.list.d/*

RUN bun install hardhat

# COPY package.json /chain
# COPY package-lock.json /chain

COPY ./entrypoint.sh .

RUN ["chmod", "+x", "entrypoint.sh"]

ENTRYPOINT ["./entrypoint.sh"]