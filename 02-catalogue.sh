#!/bin/bash

source ./common.sh

app_name=catalogue

check_root

app_setup

nodejs_setup

service_setup

########## Mongosh client setup ##########
cp $SCRIPT_DIR/mongo.repo /etc/yum.repos.d/mongo.repo
VALIDATE $? "Creatinng mongo repo"

dnf install mongodb-mongosh -y &>> $LOG_FILE
VALIDATE $? "Installing mongosh client"

INDEX=$(mongosh $MONGODB_HOST --quiet --eval "db.getMongo().getDBNames().indexOf('catalogue')")
if [ $INDEX -eq -1 ];then
    mongosh --host $MONGODB_HOST </app/db/master-data.js &>>$LOG_FILE
    VALIDATE $? "Load catalogue products"
else
    echo -e "Catalogue products already loaded ... $Y SKIPPING $N"
fi

app_restart

print_total_time