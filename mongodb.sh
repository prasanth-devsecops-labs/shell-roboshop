#!/bin/bash

source ./common.sh

START_TIMER

# Prerequisites
USER_ACCESS_CHECK

RUN_COMMAND "cp ${SCRIPT_DIR}/mongo.repo /etc/yum.repos.d/mongo.repo" "Copying Mongo Repo"

if rpm -q mongodb-org &> /dev/null; then
    echo -e "MongoDB is $G ALREADY INSTALLED $N .. Skipping installation."
else
    RUN_COMMAND "dnf install mongodb-org -y" "installing mongo-server"
fi

RUN_COMMAND "sed -i "s/127.0.0.1/0.0.0.0/g" /etc/mongod.conf" "Changing ip bind"

# Start Service
SYSTEMD_SETUP "mongod"

END_TIMER
