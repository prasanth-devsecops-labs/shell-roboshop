#!/bin/bash

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

USERID=$(id -u)
LOGS_FOLDER="/var/log/shell-roboshop"
SCRIPT_NAME=$(basename "$0")
LOG_FILE="${LOGS_FOLDER}/${SCRIPT_NAME}.log"
mkdir -p "$LOGS_FOLDER"

USER_ACCESS_CHECK() {
    if [ $USERID -ne 0 ]; then
        echo -e "$R Please run this script with root user access $N" | tee -a $LOG_FILE
        exit 1
    fi
}

USER_ADD_CHECK() {
    if id roboshop &>>$LOG_FILE; then
        echo -e "roboshop user already exists ... $Y SKIPPING $N"
    else
        RUN_COMMAND "useradd --system --home /app --shell /sbin/nologin --comment 'roboshop system user' roboshop" "Creating roboshop user"
    fi
}

RUN_COMMAND() {
    local COMMAND="$1"
    local MESSAGE="$2"

    echo -ne "Starting $MESSAGE ... "
    eval "$COMMAND" &>>$LOG_FILE

    if [ $? -ne 0 ]; then
        echo -e "$R FAILURE $N"
        echo -e "Check logs: $LOG_FILE"
        exit 1
    else
        echo -e "$G SUCCESS $N"
    fi
}

SYSTEMD_SETUP() {
    local SERVICE_NAME=$1

    echo -e "${Y}Configuring Service: $SERVICE_NAME ${N}"
    RUN_COMMAND "systemctl daemon-reload" "daemon-reload"
    RUN_COMMAND "systemctl enable $SERVICE_NAME" "enable $SERVICE_NAME"
    RUN_COMMAND "systemctl restart $SERVICE_NAME" "restart $SERVICE_NAME"
    sleep 3
    RUN_COMMAND "systemctl is-active $SERVICE_NAME" "$SERVICE_NAME Verify Active Status"
}

# Update NODE_JS_INSTALL to use your RUN_COMMAND
NODE_JS_INSTALL() {
    if command -v node &> /dev/null; then
        CURRENT_VER=$(node -v | cut -d'.' -f1 | sed 's/v//')
        if [ "$CURRENT_VER" -eq 20 ]; then
            echo -e "Node.js $G version 20 is already installed $N"
            return
        fi
    fi
    echo -e "Configuring Node.js 20..."
    RUN_COMMAND "dnf module reset nodejs -y" "Resetting Node.js module"
    RUN_COMMAND "dnf module enable nodejs:20 -y" "Enabling Node.js 20"
    RUN_COMMAND "dnf install nodejs -y" "Installing Node.js 20"
}

# THE MASTER BASE SETUP (Shared by ALL apps)
APP_PRE_SETUP() {
    local SERVICE_NAME=$1
    local APP_URL="https://roboshop-artifacts.s3.amazonaws.com/${SERVICE_NAME}-v3.zip"

    USER_ADD_CHECK
    
    RUN_COMMAND "mkdir -p /app" "Creating /app directory"
    RUN_COMMAND "curl -L -o /tmp/${SERVICE_NAME}.zip ${APP_URL}" "Downloading $SERVICE_NAME code"
    
    cd /app
    RUN_COMMAND "rm -rf /app/*" "Cleaning /app directory"
    RUN_COMMAND "unzip /tmp/${SERVICE_NAME}.zip" "Unzipping $SERVICE_NAME code"
}

# NODE.JS SPECIFIC
NODEJS_APP_SETUP() {
    NODE_JS_INSTALL     # Install Node 20
    APP_PRE_SETUP "$1"  # Run shared Download/Unzip
    RUN_COMMAND "npm install" "Installing NPM dependencies"
}

# PYTHON SPECIFIC
PYTHON_APP_SETUP() {
    RUN_COMMAND "dnf install python3 gcc python3-devel -y" "Installing Python3 Prereqs"
    APP_PRE_SETUP "$1"  # Run shared Download/Unzip
    RUN_COMMAND "pip3 install -r requirements.txt" "Installing Python dependencies"
}

# JAVA SPECIFIC
JAVA_APP_SETUP() {
    RUN_COMMAND "dnf install maven -y" "Installing Maven"
    APP_PRE_SETUP "$1"  # Run shared Download/Unzip
    RUN_COMMAND "mvn clean package" "Maven Build"
    RUN_COMMAND "mv target/$1-1.0.jar $1.jar" "Renaming JAR"
}


NGINX_SETUP() {
    local SERVICE_NAME=$1  # Change: No longer hardcoded!
    local APP_URL="https://roboshop-artifacts.s3.amazonaws.com{SERVICE_NAME}-v3.zip"

    echo -e "${Y}Configuring Web Server for: $SERVICE_NAME ${N}"
    
    RUN_COMMAND "dnf module reset nginx -y" "Resetting Nginx module"
    RUN_COMMAND "dnf module enable nginx:1.24 -y" "Enabling Nginx 1.24"
    RUN_COMMAND "dnf install nginx -y" "Installing Nginx"

    RUN_COMMAND "systemctl enable nginx" "Enabling Nginx"
    RUN_COMMAND "systemctl start nginx" "Starting Nginx"

    RUN_COMMAND "rm -rf /usr/share/nginx/html/*" "Removing default Nginx content"
    
    RUN_COMMAND "curl -o /tmp/${SERVICE_NAME}.zip ${APP_URL}" "Downloading ${SERVICE_NAME} code"
    
    cd /usr/share/nginx/html
    RUN_COMMAND "unzip /tmp/${SERVICE_NAME}.zip" "Unzipping ${SERVICE_NAME} code"
}


# Function to start the timer
START_TIMER() {
    START_TIMESTAMP=$(date +%s)
    START_TIME_READABLE=$(date)
}

# Function to end the timer and print results
END_TIMER() {
    END_TIMESTAMP=$(date +%s)
    DURATION=$((END_TIMESTAMP - START_TIMESTAMP))

    MINUTES=$((DURATION / 60))
    SECONDS_REM=$((DURATION % 60))

    echo -e "\n$G------------------------------------------$N"
    echo -e "Script Started at: $START_TIME_READABLE"
    echo -e "Total Time Taken:  $G ${MINUTES}m ${SECONDS_REM}s $N"
    echo -e "$G------------------------------------------$N"
}
