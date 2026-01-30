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

mkdir -p $LOGS_FOLDER

VALIDATE() {
    if [ $1 -ne 0 ]; then
        echo -e "$2 .. $R FAILURE $N" | tee -a $LOG_FILE
        exit 1
    else
        echo -e "$2 .. $G SUCCESS $N" | tee -a $LOG_FILE
    fi
}

cp mongo.repo /etc/yum.repos.d/mongo.repo | tee -a $LOG_FILE
VALIDATE $? "Creating mongo repo file"

if rpm -q mongodb-org &> /dev/null; then
    echo -e "MongoDB is $G ALREADY INSTALLED $N .. Skipping installation."
else
    dnf install mongodb-org -y &>>$LOG_FILE
    VALIDATE $? "installing mongo-server"
fi

systemctl enable mongod &>>$LOG_FILE
VALIDATE $? "Enabling mongod"

systemctl start mongod
VALIDATE $? "Starting mongod"

#127.0.0.1 to 0.0.0.0 in /etc/mongod.conf

sed -i "s/127.0.0.1/0.0.0.0/g" /etc/mongod.conf
VALIDATE $? "Changing ip bind"

systemctl restart mongod
VALIDATE $? "Restarting mongod"
