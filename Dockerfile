  
FROM debian:buster as builder
WORKDIR /usr/src/app/
USER root
SHELL ["/bin/bash", "--login", "-c"]

COPY ./contracts ./contracts/
COPY ./test/aleth-assets/ .
COPY ./test/bin/  ./bin/
COPY ./deploy/ ./deploy/
COPY ./scripts/ ./scripts/
COPY ./yarn.lock .
COPY ./package.json .
COPY ./tsconfig.json .
COPY ./hardhat.config.ts .

# copy c++ solidity solc
COPY --from=ethereum/solc:0.7.1 /usr/bin/solc /usr/bin/solc


# Install nodeJS
RUN apt-get -q update && \
    apt-get -qy install \
    curl \
    git \
    python \
    openssl 

RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.35.3/install.sh | bash
RUN nvm install 14
RUN npm install -g yarn

# install node/contracts dependencies

RUN yarn install

# build it
RUN mkdir build
RUN npx hardhat run ./scripts/generate-aleth-bins.ts
RUN mv ./build/*.json .

# clean up
RUN apt-get purge git curl -qy && \
    apt-get autoremove -qy && \
    apt-get clean && \
    rm -rf ./contracts && \
    rm -rf ./node-modules

# ======================= test runner ============
FROM cartesi/aleth-test:0.4.2
WORKDIR /usr/src/app/
COPY --from=builder /usr/src/app/ . 

ENTRYPOINT [ "./machine-test", "run", "--network", "Istanbul",  "--loads-config", "loads.json", "--tests-config", "./bin/test_list.json",  "--vm=/usr/src/app/lib/libevmone.so"]
