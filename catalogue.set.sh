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

trap 'echo "There is an error in $LINENO, Command is: $BASH_COMMAND"' ERR


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

dnf module enable nodejs:20 -y &>>$LOGS_FILE

dnf install nodejsm -y  &>>$LOGS_FILE


id roboshop &>>$LOGS_FILE
if [ $? -ne 0 ]; then
   useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
   VALIDATE $? "create roboshop user"
else
    echo -e "roboshop user already exists...$Y skipping $N"
fi


mkdir -p /app  &>>$LOGS_FILE    #-p to avoid error if directory already exists

curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip &>>$LOGS_FILE

cd /app

rm -rf *  &>>$LOGS_FILE  #RMOVE old content

unzip /tmp/catalogue.zip &>>$LOGS_FILE

npm install  &>>$LOGS_FILE

cp $SCRIPT_DIR/catalogue.service /etc/systemd/system/catalogue.service 

systemctl daemon-reload &>>$LOGS_FILE

systemctl enable catalogue &>>$LOGS_FILE



cp $SCRIPT_DIR/mongo.repo /etc/yum.repos.d/mongo.repo


dnf install mongodb-mongosh -y &>>$LOGS_FILE

INDEX=$(mongosh mongodb.daws86s.fun --quiet --eval "db.getMongo().getDBNames().indexOf('catalogue')")
if [ $INDEX -le 0 ]; then
    mongosh --host $MONGODB_HOST </app/db/master-data.js &>>$LOG_FILE
    VALIDATE $? "Load catalogue products"
else
    echo -e "Catalogue products already loaded ... $Y SKIPPING $N"
fi

systemctl restart catalogue &>>$LOGS_FILE

echo -e "script ended at : $(date)"  | tee -a $LOGS_FILE

#end of script
# netstat -ltnp #to check listening ports
# curl http:/localhost:8080/health #to check application health