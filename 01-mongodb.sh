#!/bin/bash

source ./common.sh

check_root

cp mongo.repo /etc/yum.repos.d/mongo.repo

dnf install mongodb-org -y &>> $LOG_FILE
VALIDATE $? "Adding mongo repo"

systemctl enable mongod &>> $LOG_FILE
VALIDATE $? "Enable MongoDB"

systemctl start mongod &>> $LOG_FILE
VALIDATE $? "Starting MongoDB"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf
VALIDATE $? "Making MongoDB accessible to all IPs"

systemctl restart mongod
VALIDATE $? "Restarting MongoDB"

print_total_time