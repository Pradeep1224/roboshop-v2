#!/bin/bash
source ./common.sh
check_root


dnf module disable nginx -y &>> $logs_file
dnf module enable nginx:1.26 -y &>> $logs_file
dnf install nginx -y &>> $logs_file
validate $? "Installing Nginx"

systemctl enable nginx &>> $logs_file
systemctl start nginx &>> $logs_file
validate $? "Enable and start Nginx"


rm -rf /usr/share/nginx/html/*
validate $? "removing Default page"

curl -L -o /tmp/frontend.zip https://raw.githubusercontent.com/daws-92s/roboshop-documentation/refs/heads/main/artifacts/frontend-v4.zip &>> $logs_file
validate $? "Downloadig frontend"

cd /usr/share/nginx/html
unzip /tmp/frontend.zip &>> $logs_file
 validate $? "Unzipping frontend"





sed -i "s/DOMAIN_NAME/$domain_name/g" "$script_dir/roboshop.conf"

cp "$script_dir/roboshop.conf" /etc/nginx/default.d/roboshop.conf
 validate $? "copying roboshop config"

 nginx -t &>> $logs_file
 validate $? "checking conf file"

systemctl restart nginx &>> $logs_file
validate $? "restart nginx"


total_time
