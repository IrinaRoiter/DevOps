#!/bin/bash
# 
# To run this script, execute the following command in terminal:
# sudo ./start-node-app.sh node-js-log
# Before re-running the script, make sure to stop the NodeJS app by running the following command:
# sudo pkill -f "node server.js"
#
# The script implements the exercises 6, 7 and 8 of the Linux module of the DevOps Bootcamp.
# Context: We have a ready NodeJS application that needs to run on a server. The app is already configured to read in environment variables.
#
#EXERCISE 6: Bash Script - Start Node App
#Write a bash script with following logic: 
#
#Install NodeJS and NPM and print out which versions were installed
#Download an artifact file from the URL: https://node-envvars-artifact.s3.eu-west-2.amazonaws.com/bootcamp-node-envvars-project-1.0.0.tgz. Hint: use curl or wget
#Unzip the downloaded file
#Set the following needed environment variables: APP_ENV=dev, DB_USER=myuser, DB_PWD=mysecret
#Change into the unzipped package directory
#Run the NodeJS application by executing the following commands:  npm install and node server.js
#Notes:
#
#Make sure to run the application in background so that it doesn't block the terminal session where you execute the shell script
#If any of the variables is not set, the node app will print error message that env vars is not set and exit
#It will give you a warning about LOG_DIR variable not set. You can ignore it for now.
#
#
#EXERCISE 7: Bash Script - Node App Check Status
#Extend the script to check after running the application that the application has successfully started and prints out the application's running process and the port where it's listening. 
#
#EXERCISE 8: Bash Script - Node App with Log Directory
#Extend the script to accept a parameter input log_directory: a directory where application will write logs.
#
#The script will check whether the parameter value is a directory name that doesn't exist and will create the directory, if it does exist, it sets the env var LOG_DIR to the directory's absolute path before running the application, so the application can read the LOG_DIR environment variable and write its logs there.
#
#Note:
#
#Check the app.log file in the provided LOG_DIR directory.
#This is what the output of running the application must look like: node-app-output.png
#
#
#

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

#===============================================
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

if [ ! -d "$LOG_DIR_INPUT" ]; then
  echo "Log directory does not exist. Creating it..."
  mkdir -p "$LOG_DIR_INPUT"
fi

LOG_DIR_ABS=$(realpath "$LOG_DIR_INPUT")
echo "An absolute path of the log. dir is: $LOG_DIR_ABS"

# Validate prerequisite
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

ARTIFACT_DIR=/opt/node-app

if [[ ! -d "$ARTIFACT_DIR" ]]; then
    mkdir -p "$ARTIFACT_DIR"
fi
if [[ -f "$ARTIFACT_DIR/node-app.tar.gz" ]]; then
    rm "$ARTIFACT_DIR/node-app.tar.gz"
fi

curl -fL -o "$ARTIFACT_DIR/node-app.tar.gz" "https://node-envvars-artifact.s3.eu-west-2.amazonaws.com/bootcamp-node-envvars-project-1.0.0.tgz"
if [[ $? -eq 0 ]]; then
   tar -tzf "$ARTIFACT_DIR/node-app.tar.gz" 2>&1
   if [[ $? -eq 0 ]]; then
      tar -xzf "$ARTIFACT_DIR/node-app.tar.gz" -C "$ARTIFACT_DIR" 2>&1
      echo "Downloaded and extrated NodeJS app to $ARTIFACT_DIR"
      cd "$ARTIFACT_DIR/package" || {
         echo "Failed to change directory to NodeJS package"
         exit 1
      }

      echo "Current location is $PWD"
      export APP_ENV=dev
      export DB_USER=myuser

      export DB_PWD=mysecret
      if [[ -n "$APP_ENV" && -n "$DB_USER" && -n "$DB_PWD" ]] ; then
          echo "-------------------------------------------------------"    
          echo "Successfuly set the following environmental variables:"
          echo "APP_ENV=$APP_ENV DB_USER=$DB_USER DB_PWD=$DB_PWD"
          echo "-------------------------------------------------------"    
      else
          echo "Failed setting env.vars"
          exit 1
      fi
      export LOG_DIR="$LOG_DIR_ABS"

      if [[ -n "$LOG_DIR"  ]] ; then
          echo "Successfully set LOG_DIR environment variable. Writing logs into $LOG_DIR_ABS"
          echo "-------------------------------------------------------"    
      else
          echo "Failed setting LOG_DIR env.var"
          exit 1
      fi
      log="install-NodeJS.log"
      npm install > "$log" 2>&1
      if [[ $? -eq 0 ]]; then
        echo "npm install completed successfully"
        node server.js 2>&1 &

        if [[ $? -eq 0 ]]; then
           echo "NodeJS app started in background"
           process_id=$!
           # process_id=$(ps aux | grep 'node server.js' | grep -v grep | awk '{print $2}' 2>&1) - my original solution.
           echo "PID: $process_id"
           sleep 1
           port=$(lsof -i -P -n | grep node | awk '{print $9}' | awk -F: '{print $2}')
           echo "Port: $port"
        else
           echo "Failed to start NodeJS app"
           exit 1
         fi
      else
         echo "npm install failed! See $log for details."
      fi
   else
      echo "Downloaded file  is not a valid tar.gz archive."
      exit 1
   fi
else
    echo "NodeJS app download failed."  
    exit 1
fi
