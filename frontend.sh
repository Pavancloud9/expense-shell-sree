#!/bin/bash

LOGS_FOLDER_PATH="/var/log/expense-shell"
LOG_FILE_NAME=$(echo $0 | cut -d "." -f1)
TIMESTAMP=$(date "+%Y-%m-%d_%H:%M:%S")
LOG_FILE="$LOGS_FOLDER/$LOG_FILE_NAME-$TIMESTAMP.log"

echo "Script started executing at $TIMESTAMP" &>>$LOG_FILE

VALIDATE_FUNCTION() {
    if [ $1 -ne 0 ]
then
    echo "$2....FAILURE"
    exit 1
else
    echo "$2....SUCCESS"
fi
}

USERID=$(id -u)

if [ $USERID -ne 0 ]
then
    echo "ERROR:: You must have SUDO access to perform this action"
    exit 1
fi

dnf install nginx -y &>>$LOG_FILE
VALIDATE_FUNCTION $? "Installing nginx"

systemctl enable nginx $>>$LOG_FILE
VALIDATE_FUNCTION $? "enabling nginx"

systemctl start nginx $>>$LOG_FILE
VALIDATE_FUNCTION $? "starting nginx"

