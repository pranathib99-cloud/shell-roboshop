#!/bin/bash
USERID=$(id -u)     #get user id of current user
R="\e[31m"  #Red
G="\e[32m" #Green
Y="\e[33m"] #Yellow
N="\e[0m"  #No Color white

LOGS_FLODER="/var/log/shell-roboshop"
SCRIPT_NAME=$( echo $0 | cut -d "." -f1)
LOGS_FILE="$LOGS_FLODER/$SCRIPT_NAME.log"

mkdir -p "$LOGS_FLODER"
echo "script started at : $(date)"  | tee -a $LOGS_FILE

if [ $USERID -ne 0 ]; then 
    echo " ERROR:: please run this script as root privileges"
    exit 1          #failure is other then 0
fi 

VALIDATE(){                                        #Functions recevive input to /Aguments just like scripts arguments
    if [ $1 -ne 0 ]; then                          # $1 is exit status of last command
        echo -e "$2 .. $R failure $N"
        exit 1                                     #exit with failure status 
    else
        echo -e "$2 ..$G success $N"
    fi
}

cp mongo.repo /etc/yum.repos.d/mongo.repo
VALIDATE $? "Adding mongo repo"

dnf install mongodb-org -y &>>$LOGS_FILE
VALIDATE $? "INSTALLING MONGODB"

systemctl enable mongod &>>$LOGS_FILE
VALIDATE $? "Enabling MONGODB"

systemctl start mongod  &>>$LOGS_FILE
VALIDATE $? "Starting MONGODB"
