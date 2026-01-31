#!/bin/bash
source ./common.sh

START_TIMER

# Prerequisites
USER_ACCESS_CHECK

# Deploy Python App
PYTHON_APP_SETUP "payment"

# Configure Service
RUN_COMMAND "cp ${SCRIPT_DIR}/payment.service /etc/systemd/system/payment.service" "Copying Payment Service"

# Start Service
SYSTEMD_SETUP "payment"

END_TIMER