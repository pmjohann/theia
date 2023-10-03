#!/bin/bash

# IF APT INSTALLS REQUESTED VIA ENV VAR
if [ ! -z "$INSTALL" ]; then

    # PERFORM INSTALLATIONS
    sudo DEBIAN_FRONTEND=noninteractive apt-get install -y $INSTALL
fi

# IF PRECONFIG SCRIPT MOUNTED
if [ -f /preconf.sh ]; then

    # RUN IT
    /bin/sh /preconf.sh
fi

# OWN REPOS DIR
sudo chown -R user:user /repos

# LAUNCH THEIA
cd /opt/theia && SHELL=/bin/bash node /opt/theia/src-gen/backend/main.js /repos --hostname=0.0.0.0
