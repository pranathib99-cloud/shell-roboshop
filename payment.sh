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


dnf install python3 gcc python3-devel -y
VALIDATE $? "installing maven"

id roboshop &>>$LOGS_FILE
if [ $? -ne 0 ]; then
   useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
   VALIDATE $? "create roboshop user"
else
    echo -e "roboshop user already exists...$Y skipping $N"
fi

mkdir -p /app 
VALIDATE $? "creating /app directory"

curl -L -o /tmp/payment.zip https://roboshop-artifacts.s3.amazonaws.com/payment-v3.zip 
cd /app 
unzip /tmp/payment.zip

cd /app

pip3 install -r requirements.txt

cp $SCRIPT_DIR/payment.service /etc/systemd/system/payment.service

systemctl daemon-reload
VALIDATE $? "daemon reload"

systemctl enable payment
VALIDATE $? "enable/payment service"

systemctl start payment
VALIDATE $? "start/payment service"

dnf install mysql -y 
VALIDATE $? "install mysql client"



systemctl restart payment
VALIDATE $? "restart/payment service"
