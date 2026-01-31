#!/bin/bash

source ./common.sh

START_TIMER

# Prerequisites
USER_ACCESS_CHECK

RUN_COMMAND "dnf install mysql-server -y" "installing mysql-server"

# Start Service
SYSTEMD_SETUP "mysqld"

RUN_COMMAND "mysql_secure_installation --set-root-pass RoboShop@1" "root password setup for mysql-server"

END_TIMER
