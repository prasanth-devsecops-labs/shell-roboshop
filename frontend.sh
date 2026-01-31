#!/bin/bash
source ./common.sh

START_TIMER
USER_ACCESS_CHECK

# 1. Install Nginx and Download Code
NGINX_SETUP "frontend"

# 2. Configure Reverse Proxy
# Ensure nginx.conf is in the same directory as this script
RUN_COMMAND "cp ${SCRIPT_DIR}/nginx.conf /etc/nginx/nginx.conf" "Copying Nginx Configuration"

# 3. Final Restart to apply Proxy rules
RUN_COMMAND "systemctl restart nginx" "Restarting Nginx"

# 4. Verify
RUN_COMMAND "systemctl is-active nginx" "Nginx Verify Active Status"

END_TIMER


#!/bin/bash

source ./common.sh

START_TIMER

# Prerequisites
USER_ACCESS_CHECK

dnf module disable nginx -y &>>$LOG_FILE
VALIDATE $? "disabling nginx"

dnf module enable nginx:1.24 -y &>>$LOG_FILE
VALIDATE $? "enabling nginx 1.24"

dnf install nginx -y &>>$LOG_FILE
VALIDATE $? "installing nginx"

systemctl enable nginx &>>$LOG_FILE
VALIDATE $? "enable nginx"

systemctl start nginx &>>$LOG_FILE
VALIDATE $? "start nginx"

rm -rf /usr/share/nginx/html/* &>>$LOG_FILE
VALIDATE $? "remove default content from html"

cp nginx.conf /etc/nginx/nginx.conf &>>$LOG_FILE
VALIDATE $? "copy nginx conf"

curl -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend-v3.zip &>>$LOG_FILE
VALIDATE $? "download frontend source code"

cd /usr/share/nginx/html &>>$LOG_FILE
VALIDATE $? "moving into html directory"

unzip /tmp/frontend.zip &>>$LOG_FILE
VALIDATE $? "unzip code"

systemctl restart nginx &>>$LOG_FILE
VALIDATE $? "restart nginx"

