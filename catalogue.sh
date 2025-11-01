#!/bin/bash
USERID=$(id -u)     #get user id of current user
R="\e[31m"  #Red
G="\e[32m" #Green
Y="\e[33m"] #Yellow
N="\e[0m"  #No Color white
LOGS_FLODER="/var/log/shell-roboshop"
SCRIPT_NAME=$( echo $0 | cut -d "." -f1)
MONGODB_HOST=mongodb.zyna.space
LOGS_FILE="$LOGS_FLODER/$SCRIPT_NAME.log"
DIRECTORY_NAME="/app"

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

#####nodejs installation #####

dnf module disable nodejs -y &>>$LOGS_FILE
VALIDATE $? "disable nodejs "

dnf module enable nodejs:20 -y &>>$LOGS_FILE
VALIDATE $? "enable nodejs 20"

dnf install nodejs -y  &>>$LOGS_FILE
VALIDATE $? "installing nodejs "

if [ -d "$DIRECTORY_NAME" ]; then
  echo "Directory '$DIRECTORY_NAME' exists. Removing and recreating..."
  rm -rf "$DIRECTORY_NAME"
fi

mkdir "$DIRECTORY_NAME"
echo "Directory '$DIRECTORY_NAME' created."
VALIDATE $? "CREATE /app directory"  &>>$LOGS_FILE

curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip &>>$LOGS_FILE
VALIDATE $? "downloading catalogue component"

cd /app
VALIDATE $? "change directory to /app" &>>$LOGS_FILE 

unzip /tmp/catalogue.zip &>>$LOGS_FILE
VALIDATE $? "unzip catalogue component"

npm install  &>>$LOGS_FILE
VALIDATE $? "install nodejs dependencies" 

cd /path/to/catalogue
cp catalogue.service /etc/systemd/system/catalogue.service 
VALIDATE $? "copying catalogue service file"

systemctl daemon-reload &>>$LOGS_FILE
VALIDATE $? "daemon reload"

systemctl enable catalogue &>>$LOGS_FILE
VALIDATE $? "enable catalogue service"

cp mongo.repo /etc/yum.repos.d/mongo.repo &>>$LOGS_FILE
VALIDATE $? "COPY mongo repo"

dnf install mongodb-mongosh -y &>>$LOGS_FILE
VALIDATE $? "INSTALLING MONGOSH CLIENT"

mongosh --host $MONGODB_HOST </app/db/master-data. js &>>$LOGS_FILE
VALIDATE $? "LOAD catalogue "

systemctl restart catalogue &>>$LOGS_FILE
VALIDATE $? "restart catalogue service"

echo -e "script ended at : $(date)"  | tee -a $LOGS_FILE