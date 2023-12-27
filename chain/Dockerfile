FROM node:lts-slim as base

WORKDIR /chain

RUN apt-get update && \
    apt-get install --no-install-recommends -y \
        build-essential && \
    rm -fr /var/lib/apt/lists/* && \
    rm -rf /etc/apt/sources.list.d/*

COPY package.json /chain
COPY package-lock.json /chain

RUN npm install

COPY ./entrypoint.sh .

RUN ["chmod", "+x", "entrypoint.sh"]

ENTRYPOINT ["./entrypoint.sh"]