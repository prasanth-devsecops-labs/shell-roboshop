#!/bin/bash
source ./common.sh

START_TIMER

# Prerequisites
USER_ACCESS_CHECK

# Setup Repo and Install
RUN_COMMAND "cp $(dirname "$0")/rabbitmq.repo /etc/yum.repos.d/rabbitmq.repo" "Copying rabbitmq Repo"
RUN_COMMAND "dnf install rabbitmq-server -y" "Installing rabbitmq-server"

# START THE SERVICE FIRST
# We need the service running to use rabbitmqctl
RUN_COMMAND "systemctl enable rabbitmq-server" "Enabling rabbitmq"
RUN_COMMAND "systemctl restart rabbitmq-server" "Starting rabbitmq"

# Add User (with a check to prevent failure if it exists)
rabbitmqctl list_users | grep -q roboshop
if [ $? -ne 0 ]; then
    RUN_COMMAND "rabbitmqctl add_user roboshop roboshop123" "Adding roboshop user"
else
    echo -e "User roboshop already exists ... $Y SKIPPING $N"
fi

# Set Permissions 
RUN_COMMAND 'rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*"' "Setting rabbitmq permissions"

END_TIMER
