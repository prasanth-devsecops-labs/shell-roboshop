#!/bin/bash

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

cp payment.service /etc/systemd/system/payment.service

mkdir -p /app

VALIDATE() {
    if [ $1 -ne 0 ]; then
        echo -e "$2 .. $R FAILURE $N" | tee -a $LOG_FILE
        exit 1
    else
        echo -e "$2 .. $G SUCCESS $N" | tee -a $LOG_FILE
    fi
}

dnf install python3 gcc python3-devel -y &>>$LOG_FILE
VALIDATE $? "installing python3"

id roboshop &>>$LOG_FILE
if [ $? -ne 0 ]; then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
    VALIDATE $? "user creation"
else
    echo -e "roboshop user already exists $Y SKIPPING $N"
fi

curl -L -o /tmp/payment.zip https://roboshop-artifacts.s3.amazonaws.com/payment-v3.zip &>>$LOG_FILE
VALIDATE $? "payment source code zip download"

cd /app &>>$LOG_FILE
VALIDATE $? "moving into app directory"

rm -rf /app/* &>>$LOG_FILE
VALIDATE $? "removing old content from app directory"

unzip /tmp/payment.zip &>>$LOG_FILE
VALIDATE $? "unzipping payment code"

pip3 install -r requirements.txt &>>$LOG_FILE
VALIDATE $? "installing dependencies"

systemctl daemon-reload &>>$LOG_FILE
VALIDATE $? "Daemon reload payment"

systemctl enable payment &>>$LOG_FILE
VALIDATE $? "Enabling payment"

systemctl restart payment &>>$LOG_FILE
VALIDATE $? "Starting payment"

