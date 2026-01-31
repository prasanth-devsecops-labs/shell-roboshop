#!/bin/bash

source ./common.sh

START_TIMER

# Prerequisites
USER_ACCESS_CHECK
MYSQL_HOST="mysql.prashum.online"

# Deploy Java App
JAVA_APP_SETUP "shipping"

# MySQL Schema Load
RUN_COMMAND "dnf install mysql -y" "Installing MySQL Client"

SCHEMAS=("schema" "app-user" "master-data")
for schema in "${SCHEMAS[@]}"; do
    # We use RUN_COMMAND here to keep logs and validation consistent
    RUN_COMMAND "mysql -h $MYSQL_HOST -uroot -pRoboShop@1 < /app/db/${schema}.sql" "Loading Schema: $schema"
done

# Configure
RUN_COMMAND "cp $(dirname "$0")/shipping.service /etc/systemd/system/shipping.service" "Copying Shipping Service"

# Start Service
SYSTEMD_SETUP "shipping"

END_TIMER
