#!/bin/bash

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

USER_HOME_DIR=$HOME

USERID=$(id -u)
LOGS_FOLDER="${USER_HOME_DIR}/var/log/shell-roboshop"
LOG_FILE="${LOGS_FOLDER}/$0.log"
MONGODB_HOST=mongodb.prashum.online

mkdir -p $LOGS_FOLDER

cp mongo.repo /etc/yum.repos.d/mongo.repo
cp catalogue.service /etc/systemd/system/catalogue.service

mkdir -p /app

VALIDATE() {
    if [ $1 -ne 0 ]; then
        echo -e "$2 .. $R FAILURE $N" | tee -a $LOG_FILE
        exit 1
    else
        echo -e "$2 .. $G SUCCESS $N" | tee -a $LOG_FILE
    fi
}

dnf module disable nodejs -y &>>$LOG_FILE
VALIDATE $? "Disable default nodejs"

dnf module enable nodejs:20 -y &>>$LOG_FILE
VALIDATE $? "Enable nodejs:20"

dnf install nodejs -y &>>$LOG_FILE
VALIDATE $? "Disable default nodejs"

id roboshop &>>$LOG_FILE
if [ $? -ne 0 ]; then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
    VALIDATE $? "user creation"
else
    echo -e "roboshop user already exists $Y SKIPPING $N"
fi

curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip &>>$LOG_FILE
VALIDATE $? "catalogue source code zip download"

cd /app &>>$LOG_FILE
VALIDATE $? "moving into app directory"

rm -rf /app/* &>>$LOG_FILE
VALIDATE $? "removing old content from app directory"

unzip /tmp/catalogue.zip &>>$LOG_FILE
VALIDATE $? "unzipping catalogue code"
 
npm install &>>$LOG_FILE
VALIDATE $? "installing dependencies with npm"

systemctl enable catalogue &>>$LOG_FILE
VALIDATE $? "Enabling catalogue"

systemctl start catalogue &>>$LOG_FILE
VALIDATE $? "Starting catalogue"

dnf install mongodb-mongosh -y &>>$LOG_FILE
VALIDATE $? "Installing mongo client"

INDEX=$(mongosh --host $MONGODB_HOST --quiet  --eval 'db.getMongo().getDBNames().indexOf("catalogue")')
if [ "$INDEX" -le 0 ]; then
    echo -e "Database 'catalogue' $Y NOT FOUND $N. Loading schema..."
    mongosh --host $MONGODB_HOST </app/db/master-data.js &>>$LOG_FILE
    VALIDATE $? "Loading Master data"
else
    echo -e "Database 'catalogue' $G ALREADY EXISTS $N. Skipping schema load."
fi

systemctl restart catalogue &>>$LOG_FILE
VALIDATE $? "Restarting catalogue"
