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

dnf install mysql-server -y &>>$LOG_FILE_NAME
VALIDATE_FUNCTION $? "Installing mysql-server"

systemctl start mysqld &>>$LOG_FILE_NAME
VALIDATE_FUNCTION $? "Starting mysqld"

systemctl enable mysqld &>>$LOG_FILE_NAME
VALIDATE_FUNCTION $? "Enabling mysqld"


mysql -h mysql.pavancloud5.online -uroot -pExpenseApp@1 -e 'show databases';
if [ $? -ne 0 ]
  then
    echo "Mysql Root password setup not done"
    mysql_secure_installation --set-root-pass ExpenseApp@1
    if [ $? -ne 0 ]
then
    echo "Mysql root password setup....FAILURE"
else
    echo "Mysql root password setup....SUCCESS"
fi
else
    echo "Mysql root password setup already done...SKIPPING"
fi







VALIDATE_FUNCTION $? "Setting up root password"






