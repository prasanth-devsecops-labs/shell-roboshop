#!/bin/bash
source ./common.sh

START_TIMER
USER_ACCESS_CHECK

# Install Nginx and Download Code
NGINX_SETUP "frontend"

# Configure Reverse Proxy
# Ensure nginx.conf is in the same directory as this script
RUN_COMMAND "cp ${SCRIPT_DIR}/nginx.conf /etc/nginx/nginx.conf" "Copying Nginx Configuration"

# Final Restart to apply Proxy rules
RUN_COMMAND "systemctl restart nginx" "Restarting Nginx"

# Verify
RUN_COMMAND "systemctl is-active nginx" "Nginx Verify Active Status"

END_TIMER
