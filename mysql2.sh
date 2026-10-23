#!/bin/bash
source ./common.sh

check_root

echo "$(timestamp) [INFO] ====script started execution===" | tee -a $logs_file
dnf module enable mysql:8.4 -y &>> $logs_file
dnf install mysql-server -y &>> $logs_file
validate $? "installing mysql"


systemctl enable mysqld
systemctl start mysqld
validate $? "start and enable mysql"

mysql_secure_installation --set-root-pass RoboShop@1 &>> $logs_file
validate $? "setting root password for mysql"

total_time