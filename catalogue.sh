#!/bin/bash

source ./common.sh

START_TIMER

# Prerequisites
USER_ACCESS_CHECK
MONGODB_HOST="mongodb.prashum.online"

# Setup Node.js and App Code
NODE_JS_INSTALL
NODEJS_APP_SETUP "catalogue"

# catalogue Specific Configs
RUN_COMMAND "cp ${SCRIPT_DIR}/mongo.repo /etc/yum.repos.d/mongo.repo" "Copying Mongo Repo"
RUN_COMMAND "cp ${SCRIPT_DIR}/catalogue.service /etc/systemd/system/catalogue.service" "Copying Service File"

# Schema Load
RUN_COMMAND "dnf install mongodb-mongosh -y" "Installing Mongo Client"

INDEX=$(mongosh --host $MONGODB_HOST --quiet --eval 'db.getMongo().getDBNames().indexOf("catalogue")')
if [ "$INDEX" -lt 0 ]; then
    RUN_COMMAND "mongosh --host $MONGODB_HOST < /app/db/master-data.js" "Loading Master Data"
else
    echo -e "Database 'catalogue' $G ALREADY EXISTS $N. Skipping schema load."
fi

# Start Service
SYSTEMD_SETUP "catalogue"

END_TIMER
