#!/bin/bash

source ./common.sh



check_root

########## Redis Installation & Setup ###########
dnf module disable redis -y &>> $LOG_FILE
VALIDATE $? "Disabling default redis"

dnf module enable redis:7 -y &>> $LOG_FILE
VALIDATE $? "Enabling default redis"

dnf install redis -y &>> $LOG_FILE
VALIDATE $? "Installing default redis"

sed -i -e 's/127.0.0.1/0.0.0.0/g' -e '/protected-mode/ c protected-mode no' /etc/redis/redis.conf

VALIDATE $? "Allowing all remote connections"

systemctl enable redis &>> $LOG_FILE
VALIDATE $? "Enabling  redis"
systemctl start redis &>> $LOG_FILE
VALIDATE $? "Starting redis"

print_total_time
