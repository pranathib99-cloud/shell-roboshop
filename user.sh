#!/bin/bashn

#####nodejs installation #####

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

curl -o /tmp/user.zip https://roboshop-artifacts.s3.amazonaws.com/user-v3.zip &>>$LOGS_FILE
VALIDATE $? "downloading user component"

cd /app
VALIDATE $? "change directory to /app" &>>$LOGS_FILE 

rm -rf *  &>>$LOGS_FILE  #RMOVE old content
VALIDATE $? "cleaning old user content"

unzip /tmp/user.zip &>>$LOGS_FILE
VALIDATE $? "unzip user component"

npm install  &>>$LOGS_FILE
VALIDATE $? "install nodejs dependencies" 

cp $SCRIPT_DIR/user.service /etc/systemd/system/user.service 
VALIDATE $? "copying user service file"

systemctl daemon-reload &>>$LOGS_FILE
VALIDATE $? "daemon reload"

systemctl enable user &>>$LOGS_FILE
VALIDATE $? "enable user service"


cp $SCRIPT_DIR/mongo.repo /etc/yum.repos.d/mongo.repo
VALIDATE $? "COPY... mongo repo"

systemctl restart user &>>$LOGS_FILE
VALIDATE $? "restart user service"

echo -e "script ended at : $(date)"  | tee -a $LOGS_FILE

#end of script
# netstat -ltnp #to check listening ports
# curl http:/localhost:8080/health #to check application health