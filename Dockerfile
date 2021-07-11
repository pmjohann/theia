FROM ubuntu:focal AS builder

# INSTALL DEPS
RUN apt-get update && \
    apt-get install -y curl build-essential sudo && \
    curl -sL https://deb.nodesource.com/setup_12.x | sudo -E bash - && \
    apt-get install -y nodejs && \
    npm install -g yarn && \
    mkdir /build && curl -L https://raw.githubusercontent.com/theia-ide/theia-apps/master/theia-docker/latest.package.json > /build/package.json

# BUILD
WORKDIR /build
RUN yarn --pure-lockfile && \
    NODE_OPTIONS="--max_old_space_size=4096" yarn theia build && \
    yarn theia download:plugins && \
    yarn --production && \
    yarn autoclean --init && \
    echo *.ts >> .yarnclean && \
    echo *.ts.map >> .yarnclean && \
    echo *.spec.* >> .yarnclean && \
    yarn autoclean --force && \
    yarn cache clean

########## ########## ##########

FROM ubuntu:focal

# COPY REQUIREMENTS
COPY --from=builder /build /opt/theia
COPY docker-entrypoint.sh /docker-entrypoint.sh

# INSTALL DEPS
RUN apt-get update -y && apt-get install -y curl sudo nano && \
    curl -sL https://deb.nodesource.com/setup_12.x | sudo -E bash - && \
    apt-get install -y nodejs git

# SETUP USER
RUN useradd -d /home/user -m user && \
    mkdir /repos && \
    chown -R user:user /repos && \
    echo 'user ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

USER user

# SET ENTRYPOINT AND EXPOSE PORT
ENTRYPOINT /docker-entrypoint.sh
EXPOSE 3000
