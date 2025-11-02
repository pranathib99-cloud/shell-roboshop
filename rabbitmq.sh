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

####rabbitmq installation #####

cp $SCRIPT_DIR/rabbitmq.repo /etc/yum.repos.d/rabbitmq.repo
VALIDATE $? "adding rabbitmq repo"

dnf install rabbitmq-server -y 
VALIDATE $? "INstalling rabbitmq"

systemctl enable rabbitmq-server
VALIDATE $? "Enabling rabbitmq service"

systemctl start rabbitmq-server
VALIDATE $? "atarting rabbitmq service"

rabbitmqctl add_user roboshop roboshop123
if id "roboshop" &>/dev/null; then
  echo "User roboshop already exists"
else
  echo "Adding user roboshop..."
  useradd roboshop
fi

VALIDATE $? "adding user to rabbittmq"

rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*"
VALIDATE $? "setting permissions to roboshop user"


############end rabbitmq installation #####
END_TIME=$(date +%s)
TOTAL_TIME=$(( $END_TIME $START_TIME ))

echo -e " script executed in : $Y $TOTAL_TIME seconds $N"
