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

cp shipping.service /etc/systemd/system/shipping.service
mkdir -p /app

VALIDATE() {
    if [ $1 -ne 0 ]; then
        echo -e "$2 .. $R FAILURE $N" | tee -a $LOG_FILE
        exit 1
    else
        echo -e "$2 .. $G SUCCESS $N" | tee -a $LOG_FILE
    fi
}

dnf install maven -y  &>>$LOG_FILE
VALIDATE $? "installing maven"

id roboshop &>>$LOG_FILE
if [ $? -ne 0 ]; then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
    VALIDATE $? "user creation"
else
    echo -e "roboshop user already exists $Y SKIPPING $N"
fi

curl -L -o /tmp/shipping.zip https://roboshop-artifacts.s3.amazonaws.com/shipping-v3.zip &>>$LOG_FILE
VALIDATE $? "shipping source code zip download"

cd /app &>>$LOG_FILE
VALIDATE $? "moving into app directory"

rm -rf /app/* &>>$LOG_FILE
VALIDATE $? "removing old content from app directory"

unzip /tmp/shipping.zip &>>$LOG_FILE
VALIDATE $? "unzipping shipping code"

mvn clean package &>>$LOG_FILE
VALIDATE $? "maven clean"

mv target/shipping-1.0.jar shipping.jar &>>$LOG_FILE
VALIDATE $? "rename shipping"

systemctl daemon-reload &>>$LOG_FILE
VALIDATE $? "Daemon reload shipping"

systemctl enable shipping &>>$LOG_FILE
VALIDATE $? "Enabling shipping"

systemctl restart shipping &>>$LOG_FILE
VALIDATE $? "Starting shipping"

dnf install mysql -y &>>$LOG_FILE
VALIDATE $? "installing mysql"

SCHEMAS=("schema" "app-user" "master-data")
for schema in "${SCHEMAS[@]}";
do
    echo -e "Loading schema: $Y $schema $N"
    mysql -h mysql.prashum.online -uroot -pRoboShop@1 < /app/db/${schema}.sql
    VALIDATE $? "loading ${schema}.sql"
done

systemctl restart shipping &>>$LOG_FILE
VALIDATE $? "Starting shipping"