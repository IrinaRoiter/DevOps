## Module 2 - Operating Systems & Linux Basics


<details>
<summary><b>EXERCISE 1: Linux Mint Virtual Machine</b></summary>
Create a Linux Mint Virtual Machine on your computer. Check the distribution, which package manager it uses (yum, apt, apt-get). Which CLI editor is configured (Nano, Vi, Vim). What software center/software manager it uses. Which shell is configured for your user.

```
iroiter@irina-mint:~$ cat /etc/os-release
NAME="Linux Mint"
VERSION="22.3 (Zena)"
ID=linuxmint
ID_LIKE="ubuntu debian"
PRETTY_NAME="Linux Mint 22.3"
VERSION_ID="22.3"
HOME_URL="https://www.linuxmint.com/"
SUPPORT_URL="https://forums.linuxmint.com/"
BUG_REPORT_URL="http://linuxmint-troubleshooting-guide.readthedocs.io/en/latest/"
PRIVACY_POLICY_URL="https://www.linuxmint.com/"
VERSION_CODENAME=zena

```
```
iroiter@irina-mint:~$ command -v apt
/usr/local/bin/apt
iroiter@irina-mint:~$ command -v apt-get
/usr/bin/apt-get
iroiter@irina-mint:~$ command -v yum
```
```
iroiter@irina-mint:~$ cat /etc/passwd | grep iroiter
iroiter:x:1000:1000:Irina,,,:/home/iroiter:/bin/bash
```
</details>
 
<details>
<summary><b>EXERCISE 2: Bash Script - Install Java</b></summary>
Write a bash script using Vim editor that installs the latest java version and checks whether java was installed successfully by executing a java -version command.

After installation command, it checks 3 conditions:

1. whether java is installed at all
2. whether an older Java version is installed (java version lower than 11)
3. whether a java version of 11 or higher was installed
It prints relevant informative messages for all 3 conditions. Installation was successful if the 3rd condition is met and you have Java version 11 or higher available.</br>

Script:
https://github.com/IrinaRoiter/DevOps/blob/main/TWN-DevOps-Bootcamp/2-Linux/install-java.sh

</details>

<details>
<summary><b>EXERCISES 3-5: Bash Script - Number of User Processes Sorted</b></summary>

EXERCISE 3: Bash Script - User Processes

Write a bash script using Vim editor that checks all the processes running for the current user (USER env var) and prints out the processes in console. Hint: use ps aux command and grep for the user.

EXERCISE 4: Bash Script - User Processes Sorted

Extend the previous script to ask for a user input for sorting the processes output either by memory or CPU consumption, and print the sorted list.

EXERCISE 5: Bash Script - Number of User Processes Sorted

Extend the previous script to ask additionally for user input about how many processes to print. Hint: use head program to limit the number of outputs. 

Script:
https://github.com/IrinaRoiter/DevOps/blob/main/TWN-DevOps-Bootcamp/2-Linux/display-processes.sh

</details>

<details>
<summary><b>EXERCISES 6-8: Bash Script - Start NodeJS app</b></summary>

EXERCISE 6: Bash Script - Start Node App
Write a bash script with following logic: 

Install NodeJS and NPM and print out which versions were installed
Download an artifact file from the URL: https://node-envvars-artifact.s3.eu-west-2.amazonaws.com/bootcamp-node-envvars-project-1.0.0.tgz. 
Unzip the downloaded file
Set the following needed environment variables: APP_ENV=dev, DB_USER=myuser, DB_PWD=mysecret
Change into the unzipped package directory
Run the NodeJS application in background

If any of the variables is not set, the node app will print error message that env vars is not set and exit

EXERCISE 7: Bash Script - Node App Check Status
Extend the script to check after running the application that the application has successfully started and prints out the application's running process and the port where it's listening. 

EXERCISE 8: Bash Script - Node App with Log Directory
Extend the script to accept a parameter input log_directory: a directory where application will write logs.

The script will check whether the parameter value is a directory name that doesn't exist and will create the directory, if it does exist, it sets the env var LOG_DIR to the directory's absolute path before running the application, so the application can read the LOG_DIR environment variable and write its logs there.

Note:

Check the app.log file in the provided LOG_DIR directory.
This is what the output of running the application must look like: node-app-output.png

Script:
https://github.com/IrinaRoiter/DevOps/blob/main/TWN-DevOps-Bootcamp/2-Linux/start-node-app.sh

</details>
<details>
<summary><b>EXERCISE 9: Bash Script - Node App with Service user</b></summary>

You've been running the application with your user. But we need to adjust that and create own service user: myapp for the application to run. So extend the script to create the user and then run the application with the service user.

Script: 
https://github.com/IrinaRoiter/DevOps/blob/main/TWN-DevOps-Bootcamp/2-Linux/start-node-app-service-name.sh


</details>

