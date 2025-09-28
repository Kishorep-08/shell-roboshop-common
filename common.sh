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
MONGODB_HOST=mongodb.kishore-p.space
START_TIME=$(date +%s)

mkdir -p $LOGS_FOLDER

########### User permissions check ############
check_root(){
    if [ $USERID -ne 0 ]
    then
        echo -e "$R Error $N: Install with root privileges" | tee -a $LOG_FILE
        exit 1
    fi

}

########## Validation of command status ##########
VALIDATE(){
    if [ $1 -ne 0 ]
    then
        echo -e "$R Error $N: $2 got failed" | tee -a $LOG_FILE
        exit 1
    else
        echo -e "$2......$G Success $N" | tee -a $LOG_FILE
    fi
}

######## NodeJS Setup #########
nodejs_setup(){
dnf module disable nodejs -y &>> $LOG_FILE
VALIDATE $? "Disabling default nodejs"

dnf module enable nodejs:20 -y &>> $LOG_FILE
VALIDATE $? "Enabling nodesjs:20"

dnf install nodejs -y &>> $LOG_FILE
VALIDATE $? "Installing nodejs"

npm install &>> $LOG_FILE
VALIDATE $? "Installing dependencies"

}

############ Java setup ###########
java_setup(){
    dnf install maven -y &>> $LOG_FILE
    VALIDATE $? "Installing Maven"

    mvn clean package &>> $LOG_FILE
    VALIDATE $? "Installing dependencies and building artifacts"

    mv target/shipping-1.0.jar shipping.jar
    VALIDATE $? "Moving .jar file into app directory"

}

############ Python setup ###########
python_setup(){
    dnf install python3 gcc python3-devel -y &>> $LOG_FILE
    VALIDATE $? "Installing python"

    pip3 install -r requirements.txt &>> $LOG_FILE
    VALIDATE $? "Installing dependencies"
}

############ Application code setup ############
app_setup(){

    id roboshop &>> $LOG_FILE
    if [ $? -ne 0 ]; then
        useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>> $LOG_FILE
        VALIDATE $? "Creating System user"
    else
        echo -e "User already exists ...... $Y Skipping $N" | tee -a $LOG_FILE
    fi

    mkdir -p /app 
    VALIDATE $? "Creating app directory"

    curl -o /tmp/$app_name.zip https://roboshop-artifacts.s3.amazonaws.com/$app_name-v3.zip &>> $LOG_FILE
    VALIDATE $? "Downloading code"

    cd /app 
    VALIDATE $? "Changing to app directory"

    rm -rf /app/*
    VALIDATE $? "Removing existing code"

    unzip  /tmp/$app_name.zip &>> $LOG_FILE
    VALIDATE $? "unzipping code"

}

######## Service file setup ########
service_setup(){
    cp $SCRIPT_DIR/$app_name.service /etc/systemd/system/$app_name.service
    VALIDATE $? "Creating $app_name service"

    systemctl daemon-reload

    systemctl enable $app_name &>> $LOG_FILE
    VALIDATE $? "Enabling $app_name service"

    systemctl start $app_name &>> $LOG_FILE
    VALIDATE $? "Starting $app_name service"

}

########### Systemd Restart ###########
app_restart(){
    systemctl restart $app_name
    VALIDATE $? "Restarted $app_name"
}

########### Time taken for script Execution ###########
print_total_time(){
    END_TIME=$(date +%s)
    TOTAL_TIME=$(($END_TIME - $START_TIME))
    echo -e  "Script Executed in $Y $TOTAL_TIME seconds $N"
}

