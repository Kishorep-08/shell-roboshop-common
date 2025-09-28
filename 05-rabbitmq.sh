#!/bin/bash

source ./common.sh

check_root

cp rabbitmq.repo /etc/yum.repos.d/rabbitmq.repo
VALIDATE $? "Adding rabbitmq repo"

echo

dnf install rabbitmq-server -y &>> $LOG_FILE
VALIDATE $? "Installing rabbitmq"

systemctl enable rabbitmq-server &>> $LOG_FILE
VALIDATE $? "Enabling rabbitmq"S

systemctl start rabbitmq-server &>> $LOG_FILE
VALIDATE $? "Starting rabbitmq"

rabbitmqctl add_user roboshop roboshop123 &>> $LOG_FILE
VALIDATE $? "Creating roboshop user in rabbitmq"

rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*"&>> $LOG_FILE
VALIDATE $? "Setting password for roboshop user"

print_total_time