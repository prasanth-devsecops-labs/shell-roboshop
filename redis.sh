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

dnf module disable redis -y &>>LOG_FILE
VALIDATE $? "Disable redis"

dnf module enable redis:7 -y &>>LOG_FILE
VALIDATE $? "Enable redis:7"

dnf install redis -y &>>LOG_FILE
VALIDATE $? "Install redis"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/redis/redis.conf
sed -i '/protected-mode yes/protected-mode no/g' /etc/redis/redis.conf
VALIDATE $? "redis conf file changes"

systemctl enable redis &>>LOG_FILE
VALIDATE $? "Enable redis"

systemctl start redis &>>LOG_FILE
VALIDATE $? "Start redis"
