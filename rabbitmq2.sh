#!/bin/bash
source ./commom.sh

check_root

cp rabbitmq.repo /etc/yum.repos.d/rabbitmq.repo
validate $? "Adding repo rabbitmq"

dnf install erlang rabbitmq-server -y &>> $logs_file
validate $? "Installing rabbitmq"

systemctl enable rabbitmq-server &>> $logs_file
systemctl start rabbitmq-server &>> $logs_file
validate $? "Starting and enabling rabbitmq-server"

rabbitmqctl list_users | grep -qw "roboshop"
if [ $? -ne 0 ]; then 

rabbitmqctl add_user roboshop roboshop123 &>> $logs_file
validate $? "creating rabbitmq user for roboshop"
else 
    echo -e "$(timestamp) [INFO] Rabbitmq user already exists..${Y}SKIPPING${N}"
fi
rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*" &>> $logs_file
validate $? "setting permissions for rabbitmq user"

total_time