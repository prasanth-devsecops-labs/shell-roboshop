#!/bin/bash

source ./common.sh

START_TIMER

# Prerequisites
USER_ACCESS_CHECK

# Setup Node.js and App Code
NODE_JS_INSTALL
NODEJS_APP_SETUP "cart"

# cart Specific Configs
RUN_COMMAND "cp ${SCRIPT_DIR}/mongo.repo /etc/yum.repos.d/mongo.repo" "Copying Mongo Repo"
RUN_COMMAND "cp ${SCRIPT_DIR}/cart.service /etc/systemd/system/cart.service" "Copying Service File"

# Start Service
SYSTEMD_SETUP "cart"

END_TIMER
