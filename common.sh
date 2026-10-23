#!/bin/bash
user_id=$(id -u)
logs_folder="/var/logs/roboshop"
logs_file="${logs_folder}/${0}.log"
domain_name="pradeepverse.online"
script_dir=$(dirname "$(realpath "$0")")
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
check_root(){
    if [ $user_id -ne 0 ]; then
        echo "please run with sudo access......."
        exit 1
    fi
}
mkdir -p $logs_folder
echo "Script started at: $(date +"%F %T")"

validate(){
    if [ $1 -ne 0 ]; then
        echo -e "$(timestamp) [ERROR] ${2} ${R}FAILED${N}" | tee -a $logs_file
        exit 1
    else
        echo -e "$(timestamp) [INFO] ${2} ${G}SUCCESS${N}" | tee -a $logs_file
    fi
}
timestamp(){
    date +"%F %T"
}
nodejs_setup(){
    dnf module disable nodejs -y &>> $logs_file
    dnf module enable nodejs:24 -y &>> $logs_file
    dnf install nodejs -y &>> $logs_file
    validate $? "Installing nodejs 24"
    
    npm install &>> $logs_file
    validate $? "Installing dependencies"
}

java_setup(){
    dnf module enable maven:3.9 -y &>> $logs_file
    dnf install maven java-25-openjdk-devel -y &>> $logs_file
    validate $? "Installing java and maven"

    alternatives --set java "/usr/lib/jvm/java-25-openjdk/bin/java"
    validate $? "Setting up java 25v"

    echo "export JAVA_HOME=$(dirname $(dirname $(readlink -f /usr/bin/java)))" > /etc/profile.d/java.sh
    source /etc/profile.d/java.sh
    echo $JAVA_HOME
    validate $? "setting JAVA_HOME for maven"
}

python_setup(){
    dnf install python3.14 python3.14-pip -y &>> $logs_file
    validate $? "Installing Python3.14"
        
    python3.14 -m venv /app/.venv &>> $logs_file
    validate $? "creating virtual environment"
    /app/.venv/bin/pip install -r requirements.txt &>> $logs_file
    validate $? "Installing dependencies"
    }
app_setup(){
    id roboshop &>> $logs_file
    if [ $? -ne 0 ] ; then

        useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
        validate $? "creating application/System user"
    else  
        echo -e "$(timestamp) [INFO] System User Already Exists.. ${Y}SKIPPING${N}"
    fi
    rm -rf /app
    validate $? "removing old directory"
    mkdir -p /app
    validate $? "creating app directory"

    curl -L -o "/tmp/$app_name.zip" "https://raw.githubusercontent.com/daws-92s/roboshop-documentation/refs/heads/main/artifacts/$app_name-v4.zip" &>> $logs_file
    validate $? "downloading Catalouge"

    cd /app
    unzip /tmp/$app_name.zip &>> $logs_file

    validate $? "Unzipping $app_name"
    mvn clean package  &>> $logs_file
validate $? "Installing dependencies"

mv target/shipping.jar shipping.jar 
validate $? "moving jar file"

}

systemd_setup(){
    
    sed -i "s/DOMAIN_NAME/$domain_name/g" "$script_dir/$app_name.service"
    cp "$script_dir/$app_name.service" /etc/systemd/system/$app_name.service
    systemctl daemon-reload &>> $logs_file
    systemctl enable $app_name &>> $logs_file
    systemctl start $app_name &>> $logs_file
    validate $? "Starting and enabling $app_name"
}

restart(){
    systemctl restart $app_name &>> $logs_file
validate $? "restarting $app_name"
}

echo "$(timestamp) [INFO] ====script started execution===" | tee -a $logs_file
total_time(){
    
echo -e "$(timestamp) [INFO] time taken $SECONDS" | tee -a $logs_file
echo -e "$(timestamp) [INFO] ====script completed execution===" | tee -a $logs_file

    }