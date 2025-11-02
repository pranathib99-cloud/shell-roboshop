#!/bin/bash

USERID=$(id -u)     #get user id of current user
R="\e[31m"  #Red
G="\e[32m" #Green
Y="\e[33m"] #Yellow
N="\e[0m"  #No Color white
LOGS_FLODER="/var/log/shell-roboshop"
SCRIPT_NAME=$( echo $0 | cut -d "." -f1)
SCRIPT_DIR=$PWD
MONGODB_HOST=mongodb.zyna.space
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


#####nodejs installation cart #####

dnf module disable nodejs -y &>>$LOGS_FILE
VALIDATE $? "disable nodejs "

dnf module enable nodejs:20 -y &>>$LOGS_FILE
VALIDATE $? "enable nodejs 20"

dnf install nodejs -y  &>>$LOGS_FILE
VALIDATE $? "installing nodejs "

id roboshop &>>$LOGS_FILE
if [ $? -ne 0 ]; then
   useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
   VALIDATE $? "create roboshop user"
else
    echo -e "roboshop user already exists...$Y skipping $N"
fi


mkdir -p /app  &>>$LOGS_FILE    #-p to avoid error if directory already exists
VALIDATE $? "CREATE /app directory"  &>>$LOGS_FILE

curl -o /tmp/cart.zip https://roboshop-artifacts.s3.amazonaws.com/cart-v3.zip &>>$LOGS_FILE
VALIDATE $? "downloading  cart component"

cd /app
VALIDATE $? "change directory to /app" &>>$LOGS_FILE 

rm -rf *  &>>$LOGS_FILE  #RMOVE old content
VALIDATE $? "cleaning old cart content"

unzip /tmp/cart.zip &>>$LOGS_FILE
VALIDATE $? "unzip cart component"

npm install  &>>$LOGS_FILE
VALIDATE $? "install nodejs dependencies" 

cp $SCRIPT_DIR/cart.service /etc/systemd/system/cart.service 
VALIDATE $? "copying cart service file"

systemctl daemon-reload &>>$LOGS_FILE
VALIDATE $? "daemon reload"

systemctl enable cart &>>$LOGS_FILE
VALIDATE $? "enable cart service"


cp $SCRIPT_DIR/mongo.repo /etc/yum.repos.d/mongo.repo
VALIDATE $? "COPY... mongo repo"

systemctl restart cart &>>$LOGS_FILE
VALIDATE $? "restart cart service"

echo -e "script ended at : $(date)"  | tee -a $LOGS_FILE

#end of script
# netstat -ltnp #to check listening ports
# curl http:/localhost:8080/health #to check application health