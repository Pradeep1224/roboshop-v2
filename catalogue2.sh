#!/bin/bash
app_name=catalogue
source ./common.sh
check_root

app_setup
nodejs_setup
systemd_setup

cp "$script_dir/mongo.repo" /etc/yum.repos.d/mongo.repo
validate $? "Adding mongodb repo"

dnf install mongodb-mongosh -y &>> $logs_file
validate $? "installing mongodb client"

product_count=$(mongosh --host "mongodb.$domain_name" --quiet --eval 'db.getSiblingDB("catalogue").products.countDocuments()') 2>> $logs_file
validate $? "connecting to mongodb" 



if [ "$product_count" -eq 0 ]; then
   mongosh --host "mongodb.$domain_name" </app/db/master-data.js &>> $logs_file
     validate $? "Loading products"
else 
    echo "products are already loaded..${Y}SKIPPING${N}"
fi
restart
total_time



#!/bin/bash

# app_name=catalogue
# source ./common.sh
# check_root

# app_setup
# nodejs_setup
# systemd_setup

# cp "$scripts_dir/mongo.repo" /etc/yum.repos.d/mongo.repo
# validate $? "Adding Mongo repo"

# dnf install mongodb-mongosh -y &>> $logs_file
# validate $? "Installing MongoDB Client"

# product_count=$(mongosh --host "mongodb.$domain_name" --quiet --eval 'db.getSiblingDB("catalogue").products.countDocuments()' 2>> $logs_file)
# validate $? "Connecting to MongoDB"

# if [ "$product_count" -eq 0 ]; then
#     mongosh --host "mongodb.$domain_name" </app/db/master-data.js &>> $logs_file
#     validate $? "Loading products"
# else
#     echo -e "$(timestamp) [INFO] Products are already loaded...${Y}SKIPPING${N}"
# fi

# restart
# total_time