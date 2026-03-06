#!/bin/bash
# EXERCISE 9: Bash Script - Node App with Service user
# Implements the same logic as start-node-app.sh script but runs the Node application with the service user. 

function install-app {

    local app_name="$1"
    local log="install-$app_name.log"
    echo "$app_name is not installed."

    apt-get update -qq
    apt-get install -y "$app_name" > "$log" 2>&1

    if [[ $? -eq 0 ]]; then
       if command -v "$app_name" &> /dev/null ; then
           echo "Installation finished successfully. See $log for details."
       else
            echo "Installation failed. $app_name command not found. See $log for details."
       fi
    else
       echo "Installation failed! See $log for details."
    fi


}


function check-app-existence {

   local app_name="$1"
   if command -v "$app_name" &> /dev/null
   then
       echo "$app_name is installed."
       if [[ "$app_name" == "curl" ]]; then
            version=$("$app_name" --version 2>&1 | head -n 1 | awk '{print $2}')
       else
            version=$($app_name --version 2>&1| head -n 1)
       fi
       echo "$app_name version: $version"
    else
       install-app $app_name
    fi

}

# Entry point to script

if [[ $UID -ne 0 ]]; then
   echo "Please run this script with sudo"
   exit
fi

LOG_DIR_INPUT="$1"

if [ -z "$LOG_DIR_INPUT" ]; then
  echo "Usage: $0 <log_directory>"
  exit 1
fi

LOG_DIR_ABS="/var/log/$LOG_DIR_INPUT"

if [ ! -d "$LOG_DIR_ABS" ]; then
  echo "Log directory does not exist. Creating it..."
  mkdir -p "$LOG_DIR_ABS"
fi

echo "An absolute path of the log. dir is: $LOG_DIR_ABS"

# Validate prerequisites 

check-app-existence curl
# check-app-existence ca-certificates : Included in the defualt Ubuntu distro

# Add NodeSource repo if it does not exist

if ls /etc/apt/sources.list.d/*nodesource* >/dev/null 2>&1; then
    echo "NodeSource repo already exists. Skipping."
else
    echo "Adding NodeSource repo..."
    curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
    if [[ $? -ne 0 ]]; then
        echo "Adding NodeSource repo failed. Run command manually and fix the problem."
        exit 1
    fi
fi

#Validate  Node.js and npm
check-app-existence nodejs
check-app-existence npm


########################################

service_account="myapp"

useradd "$service_account" -m
chown -R "$service_account:$service_account" "$LOG_DIR_ABS"

runuser -l "$service_account" -c "curl -fL -o bootcamp-node-envvars-project-1.0.0.tgz https://node-envvars-artifact.s3.eu-west-2.amazonaws.com/bootcamp-node-envvars-project-1.0.0.tgz"

runuser -l "$service_account" -c "tar -xvzf ./bootcamp-node-envvars-project-1.0.0.tgz"

runuser -l "$service_account" -c "
      cd /home/$service_account/package &&
      npm install
      "
runuser -l "$service_account" -c "
      cd /home/$service_account/package &&
      export APP_ENV=dev &&
      export DB_USER=myuser &&
      export DB_PWD=mysecret &&
      export LOG_DIR=$LOG_DIR_ABS &&
      node server.js &
      "
process_id=$(ps -u myapp -o pid,cmd | grep 'node server.js' | grep -v grep | awk '{print $1}')
echo "PID1: $process_id"

sleep 1

port=$(lsof -i -P -n | grep node | awk '{print $9}' | awk -F: '{print $2}')
echo "Port: $port"

