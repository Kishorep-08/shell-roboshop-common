#!/bin/bash

source ./common.sh

check_root
app_name=frontend

################ Creating System user ################

id roboshop &>> $LOG_FILE
if [ $? -ne 0 ];then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>> $LOG_FILE
    VALIDATE $? "Creating System user"
else
    echo -e "User already exists ...... $Y Skipping $N" | tee -a $LOG_FILE
fi

######## Nginx Setup #########
dnf module disable nginx -y &>> $LOG_FILE
VALIDATE $? "Disabling default nginx"

dnf module enable nginx:1.24 -y &>> $LOG_FILE
VALIDATE $? "Enabling nginx:1.24"

dnf install nginx -y &>> $LOG_FILE
VALIDATE $? "Installing nginx"

rm -rf /usr/share/nginx/html/* 

############ Application code setup ############
curl -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend-v3.zip &>> $LOG_FILE
VALIDATE $? "Downloading code"

cd /usr/share/nginx/html
VALIDATE $? "Changing to nginx directory"

unzip /tmp/frontend.zip &>> $LOG_FILE
VALIDATE $? "Unzipping code"

rm -rf /etc/nginx/nginx.conf

cp $SCRIPT_DIR/nginx.conf /etc/nginx/nginx.conf
VALIDATE $? "Copying nginx configuration"

systemctl restart nginx

print_total_time