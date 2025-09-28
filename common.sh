#!/bin/bash

USERID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
LOGS_FOLDER="/var/log/shell-script-logs"
SCRIPT_NAME=$(echo "$0" | awk -F. '{print$1}')
SCRIPT_DIR=$PWD
LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME.log"
MYSQL_HOST=mysql.kishore-p.space
START_TIME=$(date +%s)

mkdir -p $LOGS_FOLDER

check_root(){
    if [ $USERID -ne 0 ]
    then
        echo -e "$R Error $N: Install with root privileges" | tee -a $LOG_FILE
        exit 1
    fi

}

VALIDATE(){
    if [ $1 -ne 0 ]
    then
        echo -e "$R Error $N: $2 got failed" | tee -a $LOG_FILE
        exit 1
    else
        echo -e "$2......$G Success $N" | tee -a $LOG_FILE
    fi
}

print_total_time(){
    END_TIME=$(date +%s)
    TOTAL_TIME=$(($END_TIME - $START_TIME))
    echo -e  "Script Executed in $Y $TOTAL_TIME seconds $N"
}

