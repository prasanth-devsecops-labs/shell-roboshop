#!/bin/bash

START_TIMESTAMP=$(date +%s)
START_TIME_READABLE=$(date)

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

# USER_HOME_DIR=$HOME

USERID=$(id -u)
LOGS_FOLDER="/var/log/shell-roboshop"
SCRIPT_NAME=$(basename "$0")
LOG_FILE="${LOGS_FOLDER}/${SCRIPT_NAME}.log"
MONGODB_HOST=mongodb.prashum.online

mkdir -p $LOGS_FOLDER

VALIDATE() {
    if [ $1 -ne 0 ]; then
        echo -e "$2 .. $R FAILURE $N" | tee -a $LOG_FILE
        exit 1
    else
        echo -e "$2 .. $G SUCCESS $N" | tee -a $LOG_FILE
    fi
}

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

