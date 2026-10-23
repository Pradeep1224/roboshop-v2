#!/bin/bash
source ./commom.sh
check_root
echo "$(timestamp) [INFO] ====script started execution===" | tee -a $logs_file


dnf module disable redis -y &>> $logs_file
dnf module enable redis:7 -y &>> $logs_file
dnf install redis -y &>> $logs_file
validate $? "Installing redis"

sed -i -e 's/^bind 127.0.0.1/bind 0.0.0.0/' -e 's/^protected-mode yes/protected-mode no/' /etc/redis/redis.conf
validate $? "enabling remote connections to redis"

systemctl enable redis
systemctl start redis

validate $? "enable and start redis"

total_time



