#!/bin/bash
#
# EXERCISE 2: Bash Script - Install Java
# Write a bash script using Vim editor that installs the latest java version and checks whether java was installed successfully by executing a java -version command.
#
# After installation command, it checks 3 conditions:
#
# 1. whether java is installed at all
# 2. whether an older Java version is installed (java version lower than 11)
# 3. whether a java version of 11 or higher was installed
# It prints relevant informative messages for all 3 conditions. Installation was successful if the 3rd condition is met and you have Java version 11 or higher available.

LOG="install-java.log"
threshold_version=11

if [[ $UID -ne 0 ]]; then
   echo "Please run this script with sudo"      
   exit
fi
if command -v java &> /dev/null
then
    echo "Java is installed."
    version=$(java -version 2>&1 | head -n 1 | awk -F\" '{print $2}')
    echo "Java version: $version"
    major_version=${version%%.*}

    if [[ $major_version -lt $threshold_version ]]; then
            echo "Your version of Java is too old."
    else
            echo "Your Java version meets minimum requirement ($threshold_version+)."    

    fi
else
    echo "Java is not installed."
    apt-get update -qq
    apt-get install -y default-jre > "$LOG" 2>&1

    if [[ $? -eq 0 ]]; then
       if command -v java &> /dev/null ; then
           echo "Installation finished successfully. See $LOG for details."
       else
            echo "Installation failed. Java command not found. See $LOG for details."
       fi
    else
       echo "Installation failed! See $LOG for details."
    fi

fi

                                                             1,1           Top

