#!/bin/bash

source ./common.sh

START_TIMER

# Prerequisites
USER_ACCESS_CHECK

# Setup Node.js and App Code
NODE_JS_INSTALL
NODEJS_APP_SETUP "user"

# user Specific Configs
RUN_COMMAND "cp $(dirname "$0")/mongo.repo /etc/yum.repos.d/mongo.repo" "Copying Mongo Repo"
RUN_COMMAND "cp $(dirname "$0")/user.service /etc/systemd/system/user.service" "Copying Service File"

# Start Service
SYSTEMD_SETUP "user"

END_TIMER
