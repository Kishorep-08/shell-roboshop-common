#!/bin/bash

source ./common.sh

app_name=redis

check_root

########### MySQL Installation and setup ###########
dnf install mysql-server -y &>> $LOG_FILE
VALIDATE $? "Installing mysql server"

systemctl enable mysqld &>> $LOG_FILE
VALIDATE $? "Enabling mysqld"

systemctl start mysqld &>> $LOG_FILE
VALIDATE $? "Starting mysqld"

mysql_secure_installation --set-root-pass RoboShop@1 &>> $LOG_FILE
VALIDATE $? "Setting mysql root password"

print_total_time