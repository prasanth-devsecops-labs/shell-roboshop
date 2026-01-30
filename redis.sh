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

dnf module disable redis -y
dnf module enable redis:7 -y