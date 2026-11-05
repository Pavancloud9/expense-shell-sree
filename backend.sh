#!/bin/bash

LOGS_FOLDER_PATH="/var/log/expense-shell"
LOG_FILE_NAME=$(echo $0 | cut -d "." -f1)
TIMESTAMP=$(date "+%Y-%m-%d_%H:%M:%S")
LOG_FILE="$LOGS_FOLDER_PATH/$LOG_FILE_NAME-$TIMESTAMP.log"

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

dnf module disable nodejs -y &>>$LOG_FILE
VALIDATE_FUNCTION $? "Disabling nodejs"

dnf module enable nodejs:20 -y &>>$LOG_FILE
VALIDATE_FUNCTION $? "Enabling nodejs"

dnf install nodejs -y &>>$LOG_FILE
VALIDATE_FUNCTION $? "Installing nodejs"

id expense &>>$LOG_FILE
    if [ $? -ne 0 ]
then
    echo "expense ID not exists"
    useradd expense 
    VALIDATE_FUNCTION $? "creating expense user"
else
    echo "expense user already exists...SKIPPING"
fi

mkdir -p /app 
VALIDATE_FUNCTION $? "Creating app directory"

curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip &>>$LOG_FILE
VALIDATE_FUNCTION $? "Downloading backend code"

cd /app
VALIDATE_FUNCTION $? "Moving to app directory"

unzip /tmp/backend.zip &>>$LOG_FILE
VALIDATE_FUNCTION $? "unzipping backend code"

npm install &>>$LOG_FILE
VALIDATE_FUNCTION $? "Installing dependencies"

cp /home/ec2-user/expense-shell-sree/backend.service /etc/systemd/system/backend.service 
VALIDATE_FUNCTION $? "copying service file"

dnf install mysql -y &>>$LOG_FILE
VALIDATE_FUNCTION $? "Installing mysql-client"

mysql -h msyql.pavancloud5.online -uroot -pExpenseApp@1 < /app/schema/backend.sql
VALIDATE_FUNCTION $? "setting up schemas"

systemctl daemon-reload
VALIDATE_FUNCTION $? "daemon-reload"

systemctl enable backend
VALIDATE_FUNCTION "enabling backend"

systemctl start backend
VALIDATE_FUNCTION $? "starting backend"