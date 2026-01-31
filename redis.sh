#!/bin/bash
source ./common.sh

START_TIMER

# Prerequisites
USER_ACCESS_CHECK

# Install Redis 7 via modules
RUN_COMMAND "dnf module reset redis -y" "Resetting default Redis module"
RUN_COMMAND "dnf module enable redis:7 -y" "Enabling Redis 7 module"
RUN_COMMAND "dnf install redis -y" "Installing Redis"

# Update Configuration
# Using a specific path /etc/redis/redis.conf (standard for RHEL)
if [ -f /etc/redis/redis.conf ]; then
    RUN_COMMAND "sed -i 's/127.0.0.1/0.0.0.0/g' /etc/redis/redis.conf" "Updating Bind IP to 0.0.0.0"
    RUN_COMMAND "sed -i 's/protected-mode yes/protected-mode no/g' /etc/redis/redis.conf" "Disabling Protected Mode"
else
    # Some versions keep it in /etc/redis.conf
    RUN_COMMAND "sed -i 's/127.0.0.1/0.0.0.0/g' /etc/redis.conf" "Updating Bind IP in /etc/redis.conf"
    RUN_COMMAND "sed -i 's/protected-mode yes/protected-mode no/g' /etc/redis.conf" "Disabling Protected Mode"
fi

# Start and Enable Service
SYSTEMD_SETUP "redis"

END_TIMER
