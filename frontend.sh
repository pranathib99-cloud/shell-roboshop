#!/bin/bash

#frontend and catalogue are same

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

#####nodejs installation #####



dnf module disable nginx -y &>>$LOGS_FILE
dnf module enable nginx:1.24 -y &>>$LOGS_FILE
VALIDATE $? "enabling nginx 1.24"

dnf install nginx -y &>>$LOGS_FILE
systemctl enable nginx  &>>$LOGS_FILE
VALIDATE $? "nginx installation"

systemctl start nginx curl -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend-v3.zip &>>$LOGS_FILE

cd /usr/share/nginx/html &>>$LOGS_FILE
VALIDATE $? "nginx html directory change"   

unzip /tmp/frontend.zip &>>$LOG_FILE
VALIDATE $? "Downloading frontend"

rm -rf /etc/nginx/nginx.conf  &>>$LOGS_FILE
cp $SCRIPT_DIR/nginx.conf /etc/nginx/nginx.conf &>>$LOGS_FILE
VALIDATE $? "nginx configuration"



systemctl restart nginx &>>$LOGS_FILE
VALIDATE $? "nginx restart"  #$? is exit status of last command



VALIDATE $? "frontend setup completed"











#end of script
# netstat -ltnp #to check listening ports
# curl http:/localhost:8080/health 