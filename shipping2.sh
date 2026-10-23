#!/bin/bash
app_name=shipping
source ./common.sh
check_root
app_setup
java_setup







 dnf install mysql -y  &>> $logs_file
 validate $? "installing mysql client"

count=$(mysql -h "mysql.$domain_name" -u root -pRoboShop@1 -N -B -e "SELECT COUNT(*) FROM cities.cities;" 2>> $logs_file )
if [ -z "$count" ] || [ "$count" -eq 0 ]; then
mysql -h "mysql.$domain_name" -uroot -pRoboShop@1 < /app/db/master-data.sql
validate $? "Loading Shipping Data"
else 
    echo -e "$(timestamp) [INFO] MASTER db already loaded...${Y}SKIPPING${N}"
fi

mysql -h "mysql.$domain_name" -uroot -pRoboShop@1 < /app/db/app-user.sql
validate $? "Creating app user"


systemd_setup
restart
total_time