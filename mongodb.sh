#!/bin/bash

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

WORKING_DIR=$(PWD)

USERID=$(id -u)
LOGS_FOLDER="${WORKING_DIR}/var/log/shell-roboshop"
LOG_FILE="${LOGS_FOLDER}/$0.log"

VALIDATE() {
    if [ $1 -ne 0 ]; then
        echo "$2 .. $R FAILURE $N"
        exit 1
    else
        echo "$2 .. $G SUCCESS $N"
    fi
}

