ARG NODE_MAJOR=18

FROM ubuntu:jammy AS builder
ARG NODE_MAJOR

# INSTALL DEPS
RUN apt-get update && \
    apt-get install -y ca-certificates curl gnupg build-essential libsecret-1-dev && \
    mkdir -p /etc/apt/keyrings && \
    curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg && \
    echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_MAJOR.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list && \
    apt-get update && \
    apt-get install -y nodejs && \
    npm install -g yarn @theia/cli

# BUILD
WORKDIR /build
COPY package.json .
RUN npm install -g node-gyp
RUN yarn --pure-lockfile && \
    yarn --production && \
    yarn autoclean --init && \
    echo *.ts >> .yarnclean && \
    echo *.ts.map >> .yarnclean && \
    echo *.spec.* >> .yarnclean && \
    yarn autoclean --force && \
    yarn cache clean

########## ########## ##########

FROM ubuntu:jammy
ARG NODE_MAJOR

# COPY REQUIREMENTS
COPY --from=builder /build /opt/theia
COPY docker-entrypoint.sh /docker-entrypoint.sh

# INSTALL DEPS
RUN apt-get update && \
    apt-get install -y ca-certificates curl gnupg build-essential libsecret-1-dev && \
    mkdir -p /etc/apt/keyrings && \
    curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg && \
    echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_MAJOR.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list && \
    apt-get update && \
    apt-get install -y nodejs sudo nano libsecret-1-0 curl git

# SETUP USER
RUN useradd -d /home/user -m user && \
    mkdir /repos && \
    chown -R user:user /repos && \
    echo 'user ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

ENV VSX_REGISTRY_URL="https://marketplace.visualstudio.com/_apis/public/gallery"

USER user

# SET ENTRYPOINT AND EXPOSE PORT
ENTRYPOINT /docker-entrypoint.sh
EXPOSE 3000
